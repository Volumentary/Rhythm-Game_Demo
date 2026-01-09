package backend.utils;

import haxe.PosInfos;

enum TraceType
{
    FATAL;
    ERROR;
	WARNING;
	TRACE;
}

class TraceUtil 
{   
    public static function log(data:Any, ?type:TraceType = TRACE, ?pos:PosInfos)
    {  
        var style:String = '';
        var color:String = '';

        switch (type)
        {
            case FATAL:
                style = '[X_X] FATAL: ';
                color = "\x1b[38;5;88m";
            case ERROR:
                style = '[X] ERROR: ';
                color = "\x1b[31m";
            case WARNING:
                style = '[!] WARNING: ';
                color = "\x1b[33m";
            case TRACE:
                style = '[/] TRACE: ';
                color = "\x1b[90m";
        }

        Sys.println(color + '(${pos.fileName}:${pos.lineNumber}) ' + style + data + "\x1b[0m");
    }
}