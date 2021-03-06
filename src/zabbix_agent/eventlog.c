/*
** Zabbix
** Copyright (C) 2000-2011 Zabbix SIA
**
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 2 of the License, or
** (at your option) any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
**/

#include "common.h"

#include "log.h"
#include "eventlog.h"
#include "winevt.h"

#define MAX_INSERT_STRS 100
#define MAX_MSG_LENGTH 1024

#define EVENTLOG_REG_PATH TEXT("SYSTEM\\CurrentControlSet\\Services\\EventLog\\")

/* open event logger and return number of records */
static int    zbx_open_eventlog(LPCTSTR wsource, HANDLE *eventlog_handle, long *pNumRecords, long *pLatestRecord)
{
	const char	*__function_name = "zbx_open_eventlog";
	TCHAR		reg_path[MAX_PATH];
	HKEY		hk = NULL;
	int		ret = FAIL;

	assert(eventlog_handle);
	assert(pNumRecords);
	assert(pLatestRecord);

	zabbix_log(LOG_LEVEL_DEBUG, "In %s()", __function_name);

	*eventlog_handle = NULL;
	*pNumRecords = 0;
	*pLatestRecord = 0;

	/* Get path to eventlog */
	zbx_wsnprintf(reg_path, MAX_PATH, EVENTLOG_REG_PATH TEXT("%s"), wsource);

	if (ERROR_SUCCESS != RegOpenKeyEx(HKEY_LOCAL_MACHINE, reg_path, 0, KEY_READ, &hk))
		goto out;

	RegCloseKey(hk);

	if (NULL == (*eventlog_handle = OpenEventLog(NULL, wsource)))	/* open log file */
		goto out;

	if (0 == GetNumberOfEventLogRecords(*eventlog_handle, (unsigned long*)pNumRecords))	/* get number of records */
		goto out;

	if (0 == GetOldestEventLogRecord(*eventlog_handle, (unsigned long*)pLatestRecord))
		goto out;

	zabbix_log(LOG_LEVEL_DEBUG, "%s() pNumRecords:%ld pLatestRecord:%ld",
			__function_name, *pNumRecords, *pLatestRecord);

	ret = SUCCEED;
out:
	zabbix_log(LOG_LEVEL_DEBUG, "End of %s():%s", __function_name, zbx_result_string(ret));

	return ret;
}

/* close event logger */
static int	zbx_close_eventlog(HANDLE eventlog_handle)
{
	if (NULL != eventlog_handle)
		CloseEventLog(eventlog_handle);

	return SUCCEED;
}

/* get Nth error from event log. 1 is the first. */
static int	zbx_get_eventlog_message(LPCTSTR wsource, HANDLE eventlog_handle, long which, char **out_source, char **out_message,
		unsigned short *out_severity, unsigned long *out_timestamp, unsigned long *out_eventid)
{
	const char	*__function_name = "zbx_get_eventlog_message";
	int		buffer_size = 512;
	EVENTLOGRECORD	*pELR = NULL;
	DWORD		dwRead, dwNeeded, dwErr;
	TCHAR		stat_buf[MAX_PATH], MsgDll[MAX_PATH];
	HKEY		hk = NULL;
	LPTSTR		pFile = NULL, pNextFile = NULL;
	DWORD		szData, Type;
	HINSTANCE	hLib = NULL;				/* handle to the messagetable DLL */
	LPTSTR		pCh, aInsertStrs[MAX_INSERT_STRS];	/* array of pointers to insert */
	LPTSTR		msgBuf = NULL;				/* hold text of the error message */
	char		*buf = NULL;
	long		i, err = 0;
	int		ret = FAIL;

	zabbix_log(LOG_LEVEL_DEBUG, "In %s() which:%ld", __function_name, which);

	*out_source	= NULL;
	*out_message	= NULL;
	*out_severity	= 0;
	*out_timestamp	= 0;
	*out_eventid	= 0;
	memset(aInsertStrs, 0, sizeof(aInsertStrs));

	pELR = (EVENTLOGRECORD *)zbx_malloc((void *)pELR, buffer_size);
retry:
	if (0 == ReadEventLog(eventlog_handle, EVENTLOG_SEEK_READ | EVENTLOG_FORWARDS_READ, which,
			pELR, buffer_size, &dwRead, &dwNeeded))
	{
		dwErr = GetLastError();
		if (dwErr == ERROR_INSUFFICIENT_BUFFER)
		{
			buffer_size = dwNeeded;
			pELR = (EVENTLOGRECORD *)zbx_realloc((void *)pELR, buffer_size);
			goto retry;
		}
		else
		{
			zabbix_log(LOG_LEVEL_DEBUG, "%s(): %s", __function_name, strerror_from_system(dwErr));
			goto out;
		}
	}

	*out_severity	= pELR->EventType;			/* return event type */
	*out_timestamp	= pELR->TimeGenerated;			/* return timestamp */
	*out_eventid	= pELR->EventID & 0xffff;
	*out_source	= zbx_unicode_to_utf8((LPTSTR)(pELR + 1));	/* copy source name */

	err = FAIL;

	/* prepare the array of insert strings for FormatMessage - the
	insert strings are in the log entry. */
	for (i = 0, pCh = (LPTSTR)((LPBYTE)pELR + pELR->StringOffset);
			i < pELR->NumStrings && i < MAX_INSERT_STRS;
			i++, pCh += zbx_strlen(pCh) + 1) /* point to next string */
	{
		aInsertStrs[i] = pCh;
	}

	/* Get path to message dll */
	zbx_wsnprintf(stat_buf, MAX_PATH, EVENTLOG_REG_PATH TEXT("%s\\%s"), wsource, (LPTSTR)(pELR + 1));

	if (ERROR_SUCCESS == RegOpenKeyEx(HKEY_LOCAL_MACHINE, stat_buf, 0, KEY_READ, &hk))
	{
		if (ERROR_SUCCESS == RegQueryValueEx(hk, TEXT("EventMessageFile"), NULL, &Type, NULL, &szData))
		{
			buf = zbx_malloc(buf, szData);
			if (ERROR_SUCCESS == RegQueryValueEx(hk, TEXT("EventMessageFile"), NULL, &Type, (LPBYTE)buf, &szData))
				pFile = (LPTSTR)buf;
		}

		RegCloseKey(hk);
	}

	err = FAIL;

	while (NULL != pFile && FAIL == err)
	{
		if (NULL != (pNextFile = zbx_strchr(pFile, ';')))
		{
			*pNextFile = '\0';
			pNextFile++;
		}

		if (ExpandEnvironmentStrings(pFile, MsgDll, MAX_PATH))
		{
			if (NULL != (hLib = LoadLibraryEx(MsgDll, NULL, LOAD_LIBRARY_AS_DATAFILE)))
			{
				/* Format the message from the message DLL with the insert strings */
				if (0 != FormatMessage(FORMAT_MESSAGE_FROM_HMODULE | FORMAT_MESSAGE_ALLOCATE_BUFFER |
						FORMAT_MESSAGE_ARGUMENT_ARRAY | FORMAT_MESSAGE_FROM_SYSTEM |
						FORMAT_MESSAGE_MAX_WIDTH_MASK,	/* do not generate new line breaks */
						hLib,				/* the messagetable DLL handle */
						pELR->EventID,			/* message ID */
						MAKELANGID(LANG_NEUTRAL, SUBLANG_ENGLISH_US),	/* language ID */
						(LPTSTR)&msgBuf,		/* address of pointer to buffer for message */
						0,
						(va_list *)aInsertStrs))	/* array of insert strings for the message */
				{
					*out_message = zbx_unicode_to_utf8(msgBuf);
					zbx_rtrim(*out_message, "\r\n ");

					/* Free the buffer that FormatMessage allocated for us. */
					LocalFree((HLOCAL)msgBuf);

					err = SUCCEED;
				}
				FreeLibrary(hLib);
			}
		}
		pFile = pNextFile;
	}

	zbx_free(buf);

	if (SUCCEED != err)
	{
		*out_message = zbx_strdcatf(*out_message, "The description for Event ID (%lu) in Source (%s) cannot be found."
				" The local computer may not have the necessary registry information or message DLL files to"
				" display messages from a remote computer.", *out_eventid, NULL == *out_source ? "" : *out_source);
		if (pELR->NumStrings)
			*out_message = zbx_strdcatf(*out_message, " The following information is part of the event: ");
		for (i = 0; i < pELR->NumStrings && i < MAX_INSERT_STRS; i++)
		{
			if (i > 0)
				*out_message = zbx_strdcatf(*out_message, "; ");
			if (aInsertStrs[i])
			{
				buf = zbx_unicode_to_utf8(aInsertStrs[i]);
				*out_message = zbx_strdcatf(*out_message, "%s", buf);
				zbx_free(buf);
			}
		}
	}

	ret = SUCCEED;
out:
	zbx_free(pELR);

	zabbix_log(LOG_LEVEL_DEBUG, "End of %s():%s", __function_name, zbx_result_string(ret));

	return ret;
}

static int	zbx_get_eventlog_message_xpath(LPCTSTR wsource, zbx_uint64_t *lastlogsize, char **out_source, char **out_message,
										   unsigned short *out_severity, unsigned long *out_timestamp, unsigned long *out_eventid, unsigned char skip_old_data, void **pcontext);

int	process_eventlog(const char *source, zbx_uint64_t *lastlogsize, unsigned long *out_timestamp, char **out_source,
		unsigned short *out_severity, char **out_message, unsigned long	*out_eventid, unsigned char skip_old_data, void **pcontext)
{
	const char	*__function_name = "process_eventlog";
	int		ret = FAIL;
	HANDLE		eventlog_handle;
	long		FirstID, LastID;
	register long	i;
	LPTSTR		wsource;
	OSVERSIONINFO	versionInfo;

	assert(NULL != lastlogsize);
	assert(NULL != out_timestamp);
	assert(NULL != out_source);
	assert(NULL != out_severity);
	assert(NULL != out_message);
	assert(NULL != out_eventid);

	zabbix_log(LOG_LEVEL_DEBUG, "In %s() source:'%s' lastlogsize:" ZBX_FS_UI64,
			__function_name, source, *lastlogsize);

	*out_timestamp = 0;
	*out_source = NULL;
	*out_severity = 0;
	*out_message = NULL;
	*out_eventid = 0;

	if (NULL == source || '\0' == *source)
	{
		zabbix_log(LOG_LEVEL_WARNING, "cannot open eventlog with empty name");
		return ret;
	}

	wsource = zbx_utf8_to_unicode(source);
	
	versionInfo.dwOSVersionInfoSize = sizeof(OSVERSIONINFO);
	GetVersionEx(&versionInfo);
	
	if (versionInfo.dwMajorVersion >= 6)
	{
		ret = zbx_get_eventlog_message_xpath(wsource, lastlogsize, out_source, out_message,
											 out_severity, out_timestamp, out_eventid, skip_old_data, pcontext);
	}
	else if (SUCCEED == zbx_open_eventlog(wsource, &eventlog_handle, &LastID /* number */, &FirstID /* oldest */))
	{
		LastID += FirstID;

		if (1 == skip_old_data)
		{
			*lastlogsize = LastID - 1;
			zabbix_log(LOG_LEVEL_DEBUG, "skipping existing data: lastlogsize:" ZBX_FS_UI64, *lastlogsize);
		}

		if (*lastlogsize > LastID)
			*lastlogsize = FirstID;
		else if (*lastlogsize >= FirstID)
			FirstID = (*lastlogsize) + 1;

		for (i = FirstID; i < LastID; i++)
		{
			if (SUCCEED == zbx_get_eventlog_message(wsource, eventlog_handle, i, out_source, out_message,
					out_severity, out_timestamp, out_eventid))
			{
				*lastlogsize = i;
				break;
			}
		}
		zbx_close_eventlog(eventlog_handle);

		ret = SUCCEED;
	}
	else
		zabbix_log(LOG_LEVEL_ERR, "cannot open eventlog '%s': %s", source, strerror_from_system(GetLastError()));

	zbx_free(wsource);

	zabbix_log(LOG_LEVEL_DEBUG, "End of %s():%s", __function_name, zbx_result_string(ret));

	return ret;
}

typedef struct {
	HANDLE handle, each_handle, context_handle, keyword_context_handle;
}zbx_eventlog_context;

#define  EvtQuery EvtQueryProc
#define  EvtCreateRenderContext EvtCreateRenderContextProc
#define  EvtNext EvtNextProc
#define  EvtRender EvtRenderProc
#define  EvtOpenPublisherMetadata EvtOpenPublisherMetadataProc
#define  EvtFormatMessage EvtFormatMessageProc
#define  EvtClose EvtCloseProc

static EVT_HANDLE (WINAPI *EvtQuery)(EVT_HANDLE, LPCWSTR, LPCWSTR, DWORD) = NULL;
static EVT_HANDLE (WINAPI *EvtCreateRenderContext)(DWORD, LPCWSTR*, DWORD) = NULL;
static BOOL (WINAPI *EvtNext)(EVT_HANDLE, DWORD, PEVT_HANDLE, DWORD, DWORD, __out PDWORD) = NULL;
static BOOL (WINAPI *EvtRender)(EVT_HANDLE, EVT_HANDLE, DWORD, DWORD, __out_bcount_part_opt(BufferSize, *BufferUsed) PVOID, __out PDWORD, __out PDWORD) = NULL;
static EVT_HANDLE (WINAPI *EvtOpenPublisherMetadata)(EVT_HANDLE, LPCWSTR, LPCWSTR, LCID, DWORD) = NULL;
static BOOL (WINAPI *EvtFormatMessage)(EVT_HANDLE, EVT_HANDLE, DWORD, DWORD, PEVT_VARIANT, DWORD, DWORD, __out_ecount_part_opt(BufferSize, *BufferUsed) LPWSTR, __out PDWORD) = NULL;
static BOOL (WINAPI *EvtClose)(EVT_HANDLE) = NULL;

int	get_eventlog_keywords(void *v, zbx_uint64_t *out_keywords)
{
	const char	*__function_name = "zbx_get_event_keyword";
	int ret = FAIL;
	zbx_eventlog_context *context = v;
	LPWSTR query = L"/Event/System/Keywords";
	PEVT_VARIANT	eventlog_array = NULL;
	DWORD		dwReturned = 0, dwValuesCount = 0, dwBufferSize = 0;
	unsigned long	status = ERROR_SUCCESS;

	zabbix_log(LOG_LEVEL_DEBUG, "In %s()", __function_name);
	*out_keywords = 0;
	context = v;
	if (context == NULL)
	{
		zabbix_log(LOG_LEVEL_WARNING, "invalid context");
		goto finish;
	}
	
	if (context->keyword_context_handle == NULL)
	{
		context->keyword_context_handle = EvtCreateRenderContext(1, &query, EvtRenderContextValues);
		if (context->keyword_context_handle == NULL)
		{
			zabbix_log(LOG_LEVEL_WARNING, "can't create render context");
			goto finish;
		}
	}
	if (!EvtRender(context->keyword_context_handle, context->each_handle, EvtRenderEventValues,
				   dwBufferSize, eventlog_array, &dwReturned, &dwValuesCount))
	{
		if (ERROR_INSUFFICIENT_BUFFER == (status = GetLastError()))
		{
			dwBufferSize = dwReturned;
			if (NULL == (eventlog_array = (PEVT_VARIANT)zbx_malloc(eventlog_array, dwBufferSize)))
			{
				zabbix_log(LOG_LEVEL_WARNING, "EvtRender malloc failed");
				goto finish;
			}
			if (!EvtRender(context->keyword_context_handle, context->each_handle, EvtRenderEventValues,
						   dwBufferSize, eventlog_array, &dwReturned, &dwValuesCount))
			{
				zabbix_log(LOG_LEVEL_WARNING, "EvtRender failed");
				goto finish;
			}
		}
		
		if (ERROR_SUCCESS != (status = GetLastError()))
		{
			zabbix_log(LOG_LEVEL_WARNING, "EvtRender failed with %d", GetLastError());
			goto finish;
		}
	}

	*out_keywords = eventlog_array[0].UInt64Val;
	ret = SUCCEED;
	
finish:
	zbx_free(eventlog_array);
	zabbix_log(LOG_LEVEL_DEBUG, "End of %s():%s", __function_name, zbx_result_string(ret));
	return ret;
}

static int	zbx_get_eventlog_message_xpath(LPCTSTR wsource, zbx_uint64_t *lastlogsize, char **out_source, char **out_message,
										   unsigned short *out_severity, unsigned long *out_timestamp, unsigned long *out_eventid,  unsigned char skip_old_data, void **pcontext)
{
	const char	*__function_name = "zbx_get_eventlog_message_xpath";
	int		ret = FAIL;
	LPSTR		tmp_str = NULL;
	LPWSTR		tmp_wstr = NULL;
	LPWSTR		event_query = NULL; /* L"Event/System[EventRecordID=WHICH]" */
	unsigned long	status = ERROR_SUCCESS;
	PEVT_VARIANT	eventlog_array = NULL;
	HANDLE			providermetadata_handle = NULL;
	LPWSTR		query_array[] = {
		L"/Event/System/Provider/@Name",
		L"/Event/System/EventID",
		L"/Event/System/Level",
		L"/Event/System/TimeCreated/@SystemTime",
		L"/Event/System/EventRecordID"};
	DWORD		array_count = 5;
	DWORD		dwReturned = 0, dwValuesCount = 0, dwBufferSize = 0;
	const ULONGLONG	sec_1970 = 116444736000000000;
	static HMODULE hmod_wevtapi = NULL;

	zbx_eventlog_context *context;

	assert(out_source);
	assert(out_message);
	assert(out_severity);
	assert(out_timestamp);
	assert(out_eventid);

	zabbix_log(LOG_LEVEL_DEBUG, "In %s() which:%lld", __function_name, *lastlogsize);
	
	*out_source	= NULL;
	*out_message	= NULL;
	*out_severity	= 0;
	*out_timestamp	= 0;
	*out_eventid = 0;

	/* We have to use LoadLibrary() to load wevtapi.dll to avoid it required even before Vista. */
	/* load wevtapi.dll once */
	if (NULL == hmod_wevtapi)
	{
		hmod_wevtapi = LoadLibrary(L"wevtapi.dll");
		if (NULL == hmod_wevtapi)
		{
			zabbix_log(LOG_LEVEL_WARNING, "Can't load wevtapi.dll");
			goto finish;
		}
		zabbix_log(LOG_LEVEL_DEBUG, "wevtapi.dll was loaded");
		/* get function pointer from wevtapi.dll */
		(FARPROC)EvtQuery = GetProcAddress(hmod_wevtapi, "EvtQuery");
		(FARPROC)EvtCreateRenderContext = GetProcAddress(hmod_wevtapi, "EvtCreateRenderContext");
		(FARPROC)EvtNext = GetProcAddress(hmod_wevtapi, "EvtNext");
		(FARPROC)EvtRender = GetProcAddress(hmod_wevtapi, "EvtRender");
		(FARPROC)EvtOpenPublisherMetadata = GetProcAddress(hmod_wevtapi, "EvtOpenPublisherMetadata");
		(FARPROC)EvtFormatMessage = GetProcAddress(hmod_wevtapi, "EvtFormatMessage");
		(FARPROC)EvtClose = GetProcAddress(hmod_wevtapi, "EvtClose");
		if (NULL == EvtQuery ||
			NULL == EvtCreateRenderContext ||
			NULL == EvtNext ||
			NULL == EvtRender ||
			NULL == EvtOpenPublisherMetadata ||
			NULL == EvtFormatMessage ||
			NULL == EvtClose)
		{
			zabbix_log(LOG_LEVEL_WARNING, "Can't load wevtapi.dll functions");
			goto finish;
		}
		zabbix_log(LOG_LEVEL_DEBUG, "wevtapi.dll functions were loaded");
	}
	
	context = *pcontext;
	if (context == NULL)
	{
		context = zbx_malloc(NULL, sizeof(*context));
		memset(context, 0, sizeof(*context));
		
		tmp_str = zbx_dsprintf(NULL, "Event/System[EventRecordID>%lld]", *lastlogsize);
		event_query = zbx_utf8_to_unicode(tmp_str);
		zbx_free(tmp_str);
		
		context->handle = EvtQuery(NULL, wsource, event_query, skip_old_data? EvtQueryChannelPath|EvtQueryReverseDirection: EvtQueryChannelPath);
		
		if (NULL == context->handle)
		{
			status = GetLastError();
			
			if (ERROR_EVT_CHANNEL_NOT_FOUND == status)
			{
				zabbix_log(LOG_LEVEL_WARNING, "Missed eventlog");
			}
			else
			{
				zabbix_log(LOG_LEVEL_WARNING, "EvtQuery failed");
			}
			goto finish;
		}
		
		context->context_handle = EvtCreateRenderContext(array_count, (LPCWSTR*)query_array, EvtRenderContextValues);
		if (NULL == context->context_handle)
		{
			zabbix_log(LOG_LEVEL_WARNING, "EvtCreateRenderContext failed");
			goto finish;
		}
		*pcontext = context;
	}

	if (context->each_handle)
	{
		EvtClose(context->each_handle);
		context->each_handle = NULL;
	}
	if (!EvtNext(context->handle, 1, &context->each_handle, INFINITE, 0, &dwReturned))
	{
		status = GetLastError();
		if (ERROR_NO_MORE_ITEMS == status)
		{
			zabbix_log(LOG_LEVEL_DEBUG, "EvtNext no more items.");
			ret = SUCCEED;
		}
		else
		{
			zabbix_log(LOG_LEVEL_WARNING, "First EvtNext failed with %lu", status);
		}
		goto finish;
	}

	if (!EvtRender(context->context_handle, context->each_handle, EvtRenderEventValues,
				   dwBufferSize, eventlog_array, &dwReturned, &dwValuesCount))
	{
		if (ERROR_INSUFFICIENT_BUFFER == (status = GetLastError()))
		{
			dwBufferSize = dwReturned;
			if (NULL == (eventlog_array = (PEVT_VARIANT)zbx_malloc(eventlog_array, dwBufferSize)))
			{
				zabbix_log(LOG_LEVEL_WARNING, "EvtRender malloc failed");
				goto finish;
			}
			if (!EvtRender(context->context_handle, context->each_handle, EvtRenderEventValues,
						   dwBufferSize, eventlog_array, &dwReturned, &dwValuesCount))
			{
				zabbix_log(LOG_LEVEL_WARNING, "EvtRender failed");
				goto finish;
			}
		}
		
		if (ERROR_SUCCESS != (status = GetLastError()))
		{
			zabbix_log(LOG_LEVEL_WARNING, "EvtRender failed with %d", status);
			goto finish;
		}
	}

	*out_source = zbx_unicode_to_utf8(eventlog_array[0].StringVal);
	
	providermetadata_handle = EvtOpenPublisherMetadata(NULL, eventlog_array[0].StringVal, NULL, 0, 0);
	if (NULL != providermetadata_handle)
	{
		dwBufferSize = 0;
		dwReturned = 0;
		
		if (!EvtFormatMessage(providermetadata_handle, context->each_handle, 0, 0,
							  NULL, EvtFormatMessageEvent, dwBufferSize, tmp_wstr, &dwReturned))
		{
			if (ERROR_INSUFFICIENT_BUFFER == (status = GetLastError()))
			{
				dwBufferSize = dwReturned;
				if (NULL == (tmp_wstr = (LPWSTR)zbx_malloc(tmp_wstr, dwBufferSize * sizeof(WCHAR))))
				{
					zabbix_log(LOG_LEVEL_WARNING, "EvtFormatMessage malloc failed");
					goto finish;
				}
				if (!EvtFormatMessage(providermetadata_handle, context->each_handle, 0, 0,
									  NULL, EvtFormatMessageEvent, dwBufferSize, tmp_wstr, &dwReturned))
				{
					zabbix_log(LOG_LEVEL_WARNING, "EvtFormatMessage failed");
					goto finish;
				}
			}
			
			if (ERROR_SUCCESS != (status = GetLastError()))
			{
				zabbix_log(LOG_LEVEL_WARNING, "EvtFormatMessage failed with %d", status);
				goto finish;
			}
		}
		*out_message= zbx_unicode_to_utf8(tmp_wstr);
	}
	else
	{
		zabbix_log(LOG_LEVEL_DEBUG, "EvtOpenPublisherMetadata failed with %d: no description availabel", GetLastError());
		*out_message = zbx_strdup(NULL, "");
	}

	*out_eventid = eventlog_array[1].UInt16Val;
	*out_severity = eventlog_array[2].ByteVal;
	*out_timestamp = (unsigned long)((eventlog_array[3].FileTimeVal - sec_1970) / 10000000);
	*lastlogsize = eventlog_array[4].UInt64Val;

	ret = SUCCEED;
	
finish:
	zbx_free(tmp_str);
	zbx_free(tmp_wstr);
	zbx_free(event_query);
	zbx_free(eventlog_array);
	if (FAIL == ret)
	{
		zbx_free(*out_source);
		zbx_free(*out_message);
	}

	if (providermetadata_handle)
		EvtClose(providermetadata_handle);

	zabbix_log(LOG_LEVEL_DEBUG, "End of %s():%s", __function_name, zbx_result_string(ret));

	return ret;
}

void	close_eventlog_context(void *v)
{
	zbx_eventlog_context *context = v;
	
	if (context == NULL || EvtClose == NULL)
		return;

	EvtClose(context->handle);
	EvtClose(context->context_handle);
	if (context->each_handle)
		EvtClose(context->each_handle);
	if (context->keyword_context_handle)
		EvtClose(context->keyword_context_handle);
	zbx_free(context);
}