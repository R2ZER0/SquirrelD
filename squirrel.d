module squirrel;

/*
Copyright (c) 2003-2011 Alberto Demichelis

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

/*
Converted to D module by Rikki "CiD" Guy (rikki.guy@gmx.com, github.com/CiD0), June 2012
*/

extern (C) {

	version (Win64) {
		version = _SQ64;
	} else version (D_LP64) {
		version = _SQ64;
	}

	version (_SQ64) {

		alias long SQInteger;
		alias ulong SQUnsignedInteger;
		alias ulong SQHash; /*should be the same size of a pointer*/
		alias int SQInt32; 
		alias uint SQUnsignedInteger32;

	}else{

		alias int SQInteger;
		alias int SQInt32; /*must be 32 bits(also on 64bits processors)*/
		alias uint SQUnsignedInteger32; /*must be 32 bits(also on 64bits processors)*/
		alias uint SQUnsignedInteger;
		alias uint SQHash; /*should be the same size of a pointer*/
	
	}

	version (SQUSEDOUBLE) {
		alias double SQFloat;
	} else {
		alias float SQFloat;
	}

	// FIXME : figure out where SQ_OBJECT_RAWINIT is used, and how to re-implement it
	version (SQUSEDOUBLE) {
		version (_SQ64) {
			alias SQUnsignedInteger SQRawObjectVal;
		} else {
			alias long SQRawObjectValue;
		}
	}else {
		version (_SQ64) {
			alias long SQRawObjectValue;
		} else {
			alias SQUnsignedInteger SQRawObjectVal;
		}
	}

	
	version (SQUSEDOUBLE) {
		enum SQ_ALIGNMENT = 8;
	}else version (_SQ64) {
		enum SQ_ALIGNMENT = 8;
	}else{
		enum SQ_ALIGNMENT = 4;
	}

	alias void* SQUserPointer;
	alias SQUnsignedInteger SQBool;
	alias SQInteger SQRESULT;

	enum SQTrue = 1;
	enum SQFalse = 0;

	struct SQVM;
	struct SQTable;
	struct SQArray;
	struct SQString;
	struct SQClosure;
	struct SQGenerator;
	struct SQNativeClosure;
	struct SQUserData;
	struct SQFunctionProto;
	struct SQRefCounted;
	struct SQClass;
	struct SQInstance;
	struct SQDelegable;
	struct SQOuter;
	struct SQWeakRef; // Added by CiD

	// Always use unicode with D
	version = SQUNICODE;

	alias wchar wchar_t;

	alias wchar_t SQChar;

	// I don't think these are really required in D...
	/*
	#define _SC(a) L##a
	#define	scstrcmp	wcscmp
	#define scsprintf	swprintf
	#define scstrlen	wcslen
	#define scstrtod	wcstod
	#ifdef _SQ64
	#define scstrtol	_wcstoi64
	#else
	#define scstrtol	wcstol
	#endif
	#define scatoi		_wtoi
	#define scstrtoul	wcstoul
	#define scvsprintf	vswprintf
	#define scstrstr	wcsstr
	#define scisspace	iswspace
	#define scisdigit	iswdigit
	#define scisxdigit	iswxdigit
	#define scisalpha	iswalpha
	#define sciscntrl	iswcntrl
	#define scisalnum	iswalnum
	#define scprintf	wprintf
	*/
	enum MAX_CHAR = 0xFFFF;

	enum SQUIRREL_VERSION =	"Squirrel 3.0.2 stable";
	enum SQUIRREL_COPYRIGHT	= "Copyright (C) 2003-2011 Alberto Demichelis";
	enum SQUIRREL_AUTHOR = "Alberto Demichelis";
	enum SQUIRREL_VERSION_NUMBER = 302;

	enum {
		SQ_VMSTATE_IDLE	=		0,
		SQ_VMSTATE_RUNNING =	1,
		SQ_VMSTATE_SUSPENDED =	2
	}

	enum SQUIRREL_EOB = 0;
	enum SQ_BYTECODE_STREAM_TAG	= 0xFAFA;

	enum SQOBJECT_REF_COUNTED =	0x08000000;
	enum SQOBJECT_NUMERIC =		0x04000000;
	enum SQOBJECT_DELEGABLE =	0x02000000;
	enum SQOBJECT_CANBEFALSE =	0x01000000;

	enum SQ_MATCHTYPEMASKSTRING = -99999;

	enum _RT_MASK = 0x00FFFFFF;
	uint _RAW_TYPE(uint type) { return ( type & _RT_MASK ); }

	enum _RT_NULL			= 0x00000001;
	enum _RT_INTEGER		= 0x00000002;
	enum _RT_FLOAT			= 0x00000004;
	enum _RT_BOOL			= 0x00000008;
	enum _RT_STRING			= 0x00000010;
	enum _RT_TABLE			= 0x00000020;
	enum _RT_ARRAY			= 0x00000040;
	enum _RT_USERDATA		= 0x00000080;
	enum _RT_CLOSURE		= 0x00000100;
	enum _RT_NATIVECLOSURE	= 0x00000200;
	enum _RT_GENERATOR		= 0x00000400;
	enum _RT_USERPOINTER	= 0x00000800;
	enum _RT_THREAD			= 0x00001000;
	enum _RT_FUNCPROTO		= 0x00002000;
	enum _RT_CLASS			= 0x00004000;
	enum _RT_INSTANCE		= 0x00008000;
	enum _RT_WEAKREF		= 0x00010000;
	enum _RT_OUTER			= 0x00020000;

	enum SQObjectType {
			OT_NULL =			(_RT_NULL|SQOBJECT_CANBEFALSE),
			OT_INTEGER =		(_RT_INTEGER|SQOBJECT_NUMERIC|SQOBJECT_CANBEFALSE),
			OT_FLOAT =			(_RT_FLOAT|SQOBJECT_NUMERIC|SQOBJECT_CANBEFALSE),
			OT_BOOL =			(_RT_BOOL|SQOBJECT_CANBEFALSE),
			OT_STRING =			(_RT_STRING|SQOBJECT_REF_COUNTED),
			OT_TABLE =			(_RT_TABLE|SQOBJECT_REF_COUNTED|SQOBJECT_DELEGABLE),
			OT_ARRAY =			(_RT_ARRAY|SQOBJECT_REF_COUNTED),
			OT_USERDATA =		(_RT_USERDATA|SQOBJECT_REF_COUNTED|SQOBJECT_DELEGABLE),
			OT_CLOSURE =		(_RT_CLOSURE|SQOBJECT_REF_COUNTED),
			OT_NATIVECLOSURE =	(_RT_NATIVECLOSURE|SQOBJECT_REF_COUNTED),
			OT_GENERATOR =		(_RT_GENERATOR|SQOBJECT_REF_COUNTED),
			OT_USERPOINTER =	_RT_USERPOINTER,
			OT_THREAD =			(_RT_THREAD|SQOBJECT_REF_COUNTED) ,
			OT_FUNCPROTO =		(_RT_FUNCPROTO|SQOBJECT_REF_COUNTED), //internal usage only
			OT_CLASS =			(_RT_CLASS|SQOBJECT_REF_COUNTED),
			OT_INSTANCE =		(_RT_INSTANCE|SQOBJECT_REF_COUNTED|SQOBJECT_DELEGABLE),
			OT_WEAKREF =		(_RT_WEAKREF|SQOBJECT_REF_COUNTED),
			OT_OUTER =			(_RT_OUTER|SQOBJECT_REF_COUNTED) //internal usage only
	}

	bool ISREFCOUNTED(uint t) { return (t & SQOBJECT_REF_COUNTED) == SQOBJECT_REF_COUNTED; }


	union SQObjectValue
	{
		SQTable *pTable;
		SQArray *pArray;
		SQClosure *pClosure;
		SQOuter *pOuter;
		SQGenerator *pGenerator;
		SQNativeClosure *pNativeClosure;
		SQString *pString;
		SQUserData *pUserData;
		SQInteger nInteger;
		SQFloat fFloat;
		SQUserPointer pUserPointer;
		SQFunctionProto *pFunctionProto;
		SQRefCounted *pRefCounted;
		SQDelegable *pDelegable;
		SQVM *pThread;
		SQClass *pClass;
		SQInstance *pInstance;
		SQWeakRef *pWeakRef;
		SQRawObjectValue raw;
	}


	struct SQObject
	{
		SQObjectType _type;
		SQObjectValue _unVal;
	}

	struct  SQMemberHandle{
		SQBool _static;
		SQInteger _index;
	}

	struct SQStackInfos{
		const SQChar* funcname;
		const SQChar* source;
		SQInteger line;
	}

	alias SQVM* HSQUIRRELVM;
	alias SQObject HSQOBJECT;
	alias SQMemberHandle HSQMEMBERHANDLE;
	alias SQInteger function(HSQUIRRELVM) SQFUNCTION;
	alias SQInteger function(SQUserPointer,SQInteger size) SQRELEASEHOOK;
	alias void function(HSQUIRRELVM,const SQChar * /*desc*/,const SQChar * /*source*/,SQInteger /*line*/,SQInteger /*column*/) SQCOMPILERERROR;
	alias void function(HSQUIRRELVM,const SQChar * ,...) SQPRINTFUNCTION;
	alias void function(HSQUIRRELVM /*v*/, SQInteger /*type*/, const SQChar * /*sourcename*/, SQInteger /*line*/, const SQChar * /*funcname*/) SQDEBUGHOOK;
	alias SQInteger function(SQUserPointer,SQUserPointer,SQInteger) SQWRITEFUNC;
	alias SQInteger function(SQUserPointer,SQUserPointer,SQInteger) SQREADFUNC;

	alias SQInteger function(SQUserPointer) SQLEXREADFUNC;

	struct SQRegFunction{
		const SQChar *name;
		SQFUNCTION f;
		SQInteger nparamscheck;
		const SQChar *typemask;
	}

	struct SQFunctionInfo {
		SQUserPointer funcid;
		const SQChar *name;
		const SQChar *source;
	}


	/*vm*/
	HSQUIRRELVM sq_open(SQInteger initialstacksize);
	HSQUIRRELVM sq_newthread(HSQUIRRELVM friendvm, SQInteger initialstacksize);
	void sq_seterrorhandler(HSQUIRRELVM v);
	void sq_close(HSQUIRRELVM v);
	void sq_setforeignptr(HSQUIRRELVM v,SQUserPointer p);
	SQUserPointer sq_getforeignptr(HSQUIRRELVM v);
	void sq_setprintfunc(HSQUIRRELVM v, SQPRINTFUNCTION printfunc,SQPRINTFUNCTION errfunc);
	SQPRINTFUNCTION sq_getprintfunc(HSQUIRRELVM v);
	SQPRINTFUNCTION sq_geterrorfunc(HSQUIRRELVM v);
	SQRESULT sq_suspendvm(HSQUIRRELVM v);
	SQRESULT sq_wakeupvm(HSQUIRRELVM v,SQBool resumedret,SQBool retval,SQBool raiseerror,SQBool throwerror);
	SQInteger sq_getvmstate(HSQUIRRELVM v);

	/*compiler*/
	SQRESULT sq_compile(HSQUIRRELVM v,SQLEXREADFUNC read,SQUserPointer p,const SQChar *sourcename,SQBool raiseerror);
	SQRESULT sq_compilebuffer(HSQUIRRELVM v,const SQChar *s,SQInteger size,const SQChar *sourcename,SQBool raiseerror);
	void sq_enabledebuginfo(HSQUIRRELVM v, SQBool enable);
	void sq_notifyallexceptions(HSQUIRRELVM v, SQBool enable);
	void sq_setcompilererrorhandler(HSQUIRRELVM v,SQCOMPILERERROR f);

	/*stack operations*/
	void sq_push(HSQUIRRELVM v,SQInteger idx);
	void sq_pop(HSQUIRRELVM v,SQInteger nelemstopop);
	void sq_poptop(HSQUIRRELVM v);
	void sq_remove(HSQUIRRELVM v,SQInteger idx);
	SQInteger sq_gettop(HSQUIRRELVM v);
	void sq_settop(HSQUIRRELVM v,SQInteger newtop);
	SQRESULT sq_reservestack(HSQUIRRELVM v,SQInteger nsize);
	SQInteger sq_cmp(HSQUIRRELVM v);
	void sq_move(HSQUIRRELVM dest,HSQUIRRELVM src,SQInteger idx);

	/*object creation handling*/
	SQUserPointer sq_newuserdata(HSQUIRRELVM v,SQUnsignedInteger size);
	void sq_newtable(HSQUIRRELVM v);
	void sq_newtableex(HSQUIRRELVM v,SQInteger initialcapacity);
	void sq_newarray(HSQUIRRELVM v,SQInteger size);
	void sq_newclosure(HSQUIRRELVM v,SQFUNCTION func,SQUnsignedInteger nfreevars);
	SQRESULT sq_setparamscheck(HSQUIRRELVM v,SQInteger nparamscheck,const SQChar *typemask);
	SQRESULT sq_bindenv(HSQUIRRELVM v,SQInteger idx);
	void sq_pushstring(HSQUIRRELVM v,const SQChar *s,SQInteger len);
	void sq_pushfloat(HSQUIRRELVM v,SQFloat f);
	void sq_pushinteger(HSQUIRRELVM v,SQInteger n);
	void sq_pushbool(HSQUIRRELVM v,SQBool b);
	void sq_pushuserpointer(HSQUIRRELVM v,SQUserPointer p);
	void sq_pushnull(HSQUIRRELVM v);
	SQObjectType sq_gettype(HSQUIRRELVM v,SQInteger idx);
	SQInteger sq_getsize(HSQUIRRELVM v,SQInteger idx);
	SQHash sq_gethash(HSQUIRRELVM v, SQInteger idx);
	SQRESULT sq_getbase(HSQUIRRELVM v,SQInteger idx);
	SQBool sq_instanceof(HSQUIRRELVM v);
	SQRESULT sq_tostring(HSQUIRRELVM v,SQInteger idx);
	void sq_tobool(HSQUIRRELVM v, SQInteger idx, SQBool *b);
	SQRESULT sq_getstring(HSQUIRRELVM v,SQInteger idx,const SQChar **c);
	SQRESULT sq_getinteger(HSQUIRRELVM v,SQInteger idx,SQInteger *i);
	SQRESULT sq_getfloat(HSQUIRRELVM v,SQInteger idx,SQFloat *f);
	SQRESULT sq_getbool(HSQUIRRELVM v,SQInteger idx,SQBool *b);
	SQRESULT sq_getthread(HSQUIRRELVM v,SQInteger idx,HSQUIRRELVM *thread);
	SQRESULT sq_getuserpointer(HSQUIRRELVM v,SQInteger idx,SQUserPointer *p);
	SQRESULT sq_getuserdata(HSQUIRRELVM v,SQInteger idx,SQUserPointer *p,SQUserPointer *typetag);
	SQRESULT sq_settypetag(HSQUIRRELVM v,SQInteger idx,SQUserPointer typetag);
	SQRESULT sq_gettypetag(HSQUIRRELVM v,SQInteger idx,SQUserPointer *typetag);
	void sq_setreleasehook(HSQUIRRELVM v,SQInteger idx,SQRELEASEHOOK hook);
	SQChar *sq_getscratchpad(HSQUIRRELVM v,SQInteger minsize);
	SQRESULT sq_getfunctioninfo(HSQUIRRELVM v,SQInteger idx,SQFunctionInfo *fi);
	SQRESULT sq_getclosureinfo(HSQUIRRELVM v,SQInteger idx,SQUnsignedInteger *nparams,SQUnsignedInteger *nfreevars);
	SQRESULT sq_setnativeclosurename(HSQUIRRELVM v,SQInteger idx,const SQChar *name);
	SQRESULT sq_setinstanceup(HSQUIRRELVM v, SQInteger idx, SQUserPointer p);
	SQRESULT sq_getinstanceup(HSQUIRRELVM v, SQInteger idx, SQUserPointer *p,SQUserPointer typetag);
	SQRESULT sq_setclassudsize(HSQUIRRELVM v, SQInteger idx, SQInteger udsize);
	SQRESULT sq_newclass(HSQUIRRELVM v,SQBool hasbase);
	SQRESULT sq_createinstance(HSQUIRRELVM v,SQInteger idx);
	SQRESULT sq_setattributes(HSQUIRRELVM v,SQInteger idx);
	SQRESULT sq_getattributes(HSQUIRRELVM v,SQInteger idx);
	SQRESULT sq_getclass(HSQUIRRELVM v,SQInteger idx);
	void sq_weakref(HSQUIRRELVM v,SQInteger idx);
	SQRESULT sq_getdefaultdelegate(HSQUIRRELVM v,SQObjectType t);
	SQRESULT sq_getmemberhandle(HSQUIRRELVM v,SQInteger idx,HSQMEMBERHANDLE *handle);
	SQRESULT sq_getbyhandle(HSQUIRRELVM v,SQInteger idx,HSQMEMBERHANDLE *handle);
	SQRESULT sq_setbyhandle(HSQUIRRELVM v,SQInteger idx,HSQMEMBERHANDLE *handle);

	/*object manipulation*/
	void sq_pushroottable(HSQUIRRELVM v);
	void sq_pushregistrytable(HSQUIRRELVM v);
	void sq_pushconsttable(HSQUIRRELVM v);
	SQRESULT sq_setroottable(HSQUIRRELVM v);
	SQRESULT sq_setconsttable(HSQUIRRELVM v);
	SQRESULT sq_newslot(HSQUIRRELVM v, SQInteger idx, SQBool bstatic);
	SQRESULT sq_deleteslot(HSQUIRRELVM v,SQInteger idx,SQBool pushval);
	SQRESULT sq_set(HSQUIRRELVM v,SQInteger idx);
	SQRESULT sq_get(HSQUIRRELVM v,SQInteger idx);
	SQRESULT sq_rawget(HSQUIRRELVM v,SQInteger idx);
	SQRESULT sq_rawset(HSQUIRRELVM v,SQInteger idx);
	SQRESULT sq_rawdeleteslot(HSQUIRRELVM v,SQInteger idx,SQBool pushval);
	SQRESULT sq_arrayappend(HSQUIRRELVM v,SQInteger idx);
	SQRESULT sq_arraypop(HSQUIRRELVM v,SQInteger idx,SQBool pushval); 
	SQRESULT sq_arrayresize(HSQUIRRELVM v,SQInteger idx,SQInteger newsize); 
	SQRESULT sq_arrayreverse(HSQUIRRELVM v,SQInteger idx); 
	SQRESULT sq_arrayremove(HSQUIRRELVM v,SQInteger idx,SQInteger itemidx);
	SQRESULT sq_arrayinsert(HSQUIRRELVM v,SQInteger idx,SQInteger destpos);
	SQRESULT sq_setdelegate(HSQUIRRELVM v,SQInteger idx);
	SQRESULT sq_getdelegate(HSQUIRRELVM v,SQInteger idx);
	SQRESULT sq_clone(HSQUIRRELVM v,SQInteger idx);
	SQRESULT sq_setfreevariable(HSQUIRRELVM v,SQInteger idx,SQUnsignedInteger nval);
	SQRESULT sq_next(HSQUIRRELVM v,SQInteger idx);
	SQRESULT sq_getweakrefval(HSQUIRRELVM v,SQInteger idx);
	SQRESULT sq_clear(HSQUIRRELVM v,SQInteger idx);

	/*calls*/
	SQRESULT sq_call(HSQUIRRELVM v,SQInteger params,SQBool retval,SQBool raiseerror);
	SQRESULT sq_resume(HSQUIRRELVM v,SQBool retval,SQBool raiseerror);
	const(SQChar) *sq_getlocal(HSQUIRRELVM v,SQUnsignedInteger level,SQUnsignedInteger idx);
	SQRESULT sq_getcallee(HSQUIRRELVM v);
	const(SQChar) *sq_getfreevariable(HSQUIRRELVM v,SQInteger idx,SQUnsignedInteger nval);
	SQRESULT sq_throwerror(HSQUIRRELVM v,const SQChar *err);
	SQRESULT sq_throwobject(HSQUIRRELVM v);
	void sq_reseterror(HSQUIRRELVM v);
	void sq_getlasterror(HSQUIRRELVM v);

	/*raw object handling*/
	SQRESULT sq_getstackobj(HSQUIRRELVM v,SQInteger idx,HSQOBJECT *po);
	void sq_pushobject(HSQUIRRELVM v,HSQOBJECT obj);
	void sq_addref(HSQUIRRELVM v,HSQOBJECT *po);
	SQBool sq_release(HSQUIRRELVM v,HSQOBJECT *po);
	SQUnsignedInteger sq_getrefcount(HSQUIRRELVM v,HSQOBJECT *po);
	void sq_resetobject(HSQOBJECT *po);
	const(SQChar) *sq_objtostring(const HSQOBJECT *o);
	SQBool sq_objtobool(const HSQOBJECT *o);
	SQInteger sq_objtointeger(const HSQOBJECT *o);
	SQFloat sq_objtofloat(const HSQOBJECT *o);
	SQUserPointer sq_objtouserpointer(const HSQOBJECT *o);
	SQRESULT sq_getobjtypetag(const HSQOBJECT *o,SQUserPointer * typetag);

	/*GC*/
	SQInteger sq_collectgarbage(HSQUIRRELVM v);
	SQRESULT sq_resurrectunreachable(HSQUIRRELVM v);

	/*serialization*/
	SQRESULT sq_writeclosure(HSQUIRRELVM vm,SQWRITEFUNC writef,SQUserPointer up);
	SQRESULT sq_readclosure(HSQUIRRELVM vm,SQREADFUNC readf,SQUserPointer up);

	/*mem allocation*/
	void *sq_malloc(SQUnsignedInteger size);
	void *sq_realloc(void* p,SQUnsignedInteger oldsize,SQUnsignedInteger newsize);
	void sq_free(void *p,SQUnsignedInteger size);

	/*debug*/
	SQRESULT sq_stackinfos(HSQUIRRELVM v,SQInteger level,SQStackInfos *si);
	void sq_setdebughook(HSQUIRRELVM v);
	void sq_setnativedebughook(HSQUIRRELVM v,SQDEBUGHOOK hook);

	/*UTILITY MACRO*/
	//#define sq_isnumeric(o) ((o)._type&SQOBJECT_NUMERIC)
	bool sq_isnumeric(SQObject o){ return (o._type & SQOBJECT_NUMERIC) == SQOBJECT_NUMERIC; }
	bool sq_istable (SQObject o){ return (o._type == SQObjectType.OT_TABLE ); }
	bool sq_isarray (SQObject o){ return (o._type == SQObjectType.OT_ARRAY ); }
	bool sq_isfunction (SQObject o){ return (o._type == SQObjectType.OT_FUNCPROTO ); }
	//#define sq_isfunction(o) ((o)._type==OT_FUNCPROTO)
	bool sq_isclosure (SQObject o){ return (o._type == SQObjectType.OT_CLOSURE ); }
	//#define sq_isclosure(o) ((o)._type==OT_CLOSURE)
	bool sq_isgenerator (SQObject o){ return (o._type == SQObjectType.OT_GENERATOR ); }
	//#define sq_isgenerator(o) ((o)._type==OT_GENERATOR)
	bool sq_isnativeclosure (SQObject o){ return (o._type == SQObjectType.OT_NATIVECLOSURE ); }
	//#define sq_isnativeclosure(o) ((o)._type==OT_NATIVECLOSURE)
	bool sq_isstring (SQObject o){ return (o._type == SQObjectType.OT_STRING ); }
	//#define sq_isstring(o) ((o)._type==OT_STRING)
	bool sq_isinteger (SQObject o){ return (o._type == SQObjectType.OT_INTEGER ); }
	//#define sq_isinteger(o) ((o)._type==OT_INTEGER)
	bool sq_isfloat (SQObject o){ return (o._type == SQObjectType.OT_FLOAT ); }
	//#define sq_isfloat(o) ((o)._type==OT_FLOAT)
	bool sq_isuserpointer (SQObject o){ return (o._type == SQObjectType.OT_USERPOINTER ); }
	//#define sq_isuserpointer(o) ((o)._type==OT_USERPOINTER)
	bool sq_isuserdata (SQObject o){ return (o._type == SQObjectType.OT_USERDATA ); }
	//#define sq_isuserdata(o) ((o)._type==OT_USERDATA)
	bool sq_isthread (SQObject o){ return (o._type == SQObjectType.OT_THREAD ); }
	//#define sq_isthread(o) ((o)._type==OT_THREAD)
	bool sq_isnull (SQObject o){ return (o._type == SQObjectType.OT_NULL ); }
	//#define sq_isnull(o) ((o)._type==OT_NULL)
	bool sq_isclass (SQObject o){ return (o._type == SQObjectType.OT_CLASS ); }
	//#define sq_isclass(o) ((o)._type==OT_CLASS)
	bool sq_isinstance (SQObject o){ return (o._type == SQObjectType.OT_INSTANCE ); }
	//#define sq_isinstance(o) ((o)._type==OT_INSTANCE)
	bool sq_isbool (SQObject o){ return (o._type == SQObjectType.OT_BOOL ); }
	//#define sq_isbool(o) ((o)._type==OT_BOOL)
	bool sq_isweakref (SQObject o){ return (o._type == SQObjectType.OT_WEAKREF ); }
	//#define sq_isweakref(o) ((o)._type==OT_WEAKREF)
	SQObjectType sq_type(SQObject o){ return o._type; }
	//#define sq_type(o) ((o)._type)

	// deprecated 
	//#define sq_createslot(v,n) sq_newslot(v,n,SQFalse)


	enum SQ_OK = 0;
	enum SQ_ERROR = -1;

	bool SQ_FAILED(int res){ return (res < 0); }
	bool SQ_SUCCEEDED(int res){ return (res >= 0); }


} /*extern (C) */
