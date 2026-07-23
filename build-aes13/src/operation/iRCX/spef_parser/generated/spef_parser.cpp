/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison implementation for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output, and Bison version.  */
#define YYBISON 30802

/* Bison version string.  */
#define YYBISON_VERSION "3.8.2"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Push parsers.  */
#define YYPUSH 0

/* Pull parsers.  */
#define YYPULL 1

/* Substitute the type names.  */
#define YYSTYPE         SPEF_STYPE
/* Substitute the variable and function names.  */
#define yyparse         spef_parse
#define yylex           spef_lex
#define yyerror         spef_error
#define yydebug         spef_debug
#define yynerrs         spef_nerrs
#define yylval          spef_lval
#define yychar          spef_char


# ifndef YY_CAST
#  ifdef __cplusplus
#   define YY_CAST(Type, Val) static_cast<Type> (Val)
#   define YY_REINTERPRET_CAST(Type, Val) reinterpret_cast<Type> (Val)
#  else
#   define YY_CAST(Type, Val) ((Type) (Val))
#   define YY_REINTERPRET_CAST(Type, Val) ((Type) (Val))
#  endif
# endif
# ifndef YY_NULLPTR
#  if defined __cplusplus
#   if 201103L <= __cplusplus
#    define YY_NULLPTR nullptr
#   else
#    define YY_NULLPTR 0
#   endif
#  else
#   define YY_NULLPTR ((void*)0)
#  endif
# endif

#include "spef_parser.hpp"
/* Symbol kind.  */
enum yysymbol_kind_t
{
  YYSYMBOL_YYEMPTY = -2,
  YYSYMBOL_YYEOF = 0,                      /* "end of file"  */
  YYSYMBOL_YYerror = 1,                    /* error  */
  YYSYMBOL_YYUNDEF = 2,                    /* "invalid token"  */
  YYSYMBOL_EOL = 3,                        /* EOL  */
  YYSYMBOL_K_NAME_MAP = 4,                 /* K_NAME_MAP  */
  YYSYMBOL_K_PORTS = 5,                    /* K_PORTS  */
  YYSYMBOL_K_CONN = 6,                     /* K_CONN  */
  YYSYMBOL_K_CAP = 7,                      /* K_CAP  */
  YYSYMBOL_K_RES = 8,                      /* K_RES  */
  YYSYMBOL_K_END = 9,                      /* K_END  */
  YYSYMBOL_K_D_NET = 10,                   /* K_D_NET  */
  YYSYMBOL_K_COORD = 11,                   /* K_COORD  */
  YYSYMBOL_K_LOAD = 12,                    /* K_LOAD  */
  YYSYMBOL_K_DRIVE = 13,                   /* K_DRIVE  */
  YYSYMBOL_K_LL = 14,                      /* K_LL  */
  YYSYMBOL_K_UR = 15,                      /* K_UR  */
  YYSYMBOL_K_LAYER = 16,                   /* K_LAYER  */
  YYSYMBOL_K_IGNORE_ATTR = 17,             /* K_IGNORE_ATTR  */
  YYSYMBOL_HEADER_KEY = 18,                /* HEADER_KEY  */
  YYSYMBOL_CONN_TYPE = 19,                 /* CONN_TYPE  */
  YYSYMBOL_DIRECTION = 20,                 /* DIRECTION  */
  YYSYMBOL_NAME_REF = 21,                  /* NAME_REF  */
  YYSYMBOL_SPEF_NAME = 22,                 /* SPEF_NAME  */
  YYSYMBOL_QUOTED_STRING = 23,             /* QUOTED_STRING  */
  YYSYMBOL_NUMBER = 24,                    /* NUMBER  */
  YYSYMBOL_YYACCEPT = 25,                  /* $accept  */
  YYSYMBOL_spef_file = 26,                 /* spef_file  */
  YYSYMBOL_lines = 27,                     /* lines  */
  YYSYMBOL_line = 28,                      /* line  */
  YYSYMBOL_section_line = 29,              /* section_line  */
  YYSYMBOL_header_line = 30,               /* header_line  */
  YYSYMBOL_31_1 = 31,                      /* $@1  */
  YYSYMBOL_header_values = 32,             /* header_values  */
  YYSYMBOL_header_value = 33,              /* header_value  */
  YYSYMBOL_name_map_entry = 34,            /* name_map_entry  */
  YYSYMBOL_port_entry = 35,                /* port_entry  */
  YYSYMBOL_dnet_entry = 36,                /* dnet_entry  */
  YYSYMBOL_conn_entry = 37,                /* conn_entry  */
  YYSYMBOL_conn_start = 38,                /* conn_start  */
  YYSYMBOL_conn_attrs = 39,                /* conn_attrs  */
  YYSYMBOL_conn_attr = 40,                 /* conn_attr  */
  YYSYMBOL_cap_res_entry = 41,             /* cap_res_entry  */
  YYSYMBOL_direction_opt = 42,             /* direction_opt  */
  YYSYMBOL_direction = 43,                 /* direction  */
  YYSYMBOL_conn_type = 44,                 /* conn_type  */
  YYSYMBOL_name_token = 45,                /* name_token  */
  YYSYMBOL_name_value_token = 46           /* name_value_token  */
};
typedef enum yysymbol_kind_t yysymbol_kind_t;




#ifdef short
# undef short
#endif

/* On compilers that do not define __PTRDIFF_MAX__ etc., make sure
   <limits.h> and (if available) <stdint.h> are included
   so that the code can choose integer types of a good width.  */

#ifndef __PTRDIFF_MAX__
# include <limits.h> /* INFRINGES ON USER NAME SPACE */
# if defined __STDC_VERSION__ && 199901 <= __STDC_VERSION__
#  include <stdint.h> /* INFRINGES ON USER NAME SPACE */
#  define YY_STDINT_H
# endif
#endif

/* Narrow types that promote to a signed type and that can represent a
   signed or unsigned integer of at least N bits.  In tables they can
   save space and decrease cache pressure.  Promoting to a signed type
   helps avoid bugs in integer arithmetic.  */

#ifdef __INT_LEAST8_MAX__
typedef __INT_LEAST8_TYPE__ yytype_int8;
#elif defined YY_STDINT_H
typedef int_least8_t yytype_int8;
#else
typedef signed char yytype_int8;
#endif

#ifdef __INT_LEAST16_MAX__
typedef __INT_LEAST16_TYPE__ yytype_int16;
#elif defined YY_STDINT_H
typedef int_least16_t yytype_int16;
#else
typedef short yytype_int16;
#endif

/* Work around bug in HP-UX 11.23, which defines these macros
   incorrectly for preprocessor constants.  This workaround can likely
   be removed in 2023, as HPE has promised support for HP-UX 11.23
   (aka HP-UX 11i v2) only through the end of 2022; see Table 2 of
   <https://h20195.www2.hpe.com/V2/getpdf.aspx/4AA4-7673ENW.pdf>.  */
#ifdef __hpux
# undef UINT_LEAST8_MAX
# undef UINT_LEAST16_MAX
# define UINT_LEAST8_MAX 255
# define UINT_LEAST16_MAX 65535
#endif

#if defined __UINT_LEAST8_MAX__ && __UINT_LEAST8_MAX__ <= __INT_MAX__
typedef __UINT_LEAST8_TYPE__ yytype_uint8;
#elif (!defined __UINT_LEAST8_MAX__ && defined YY_STDINT_H \
       && UINT_LEAST8_MAX <= INT_MAX)
typedef uint_least8_t yytype_uint8;
#elif !defined __UINT_LEAST8_MAX__ && UCHAR_MAX <= INT_MAX
typedef unsigned char yytype_uint8;
#else
typedef short yytype_uint8;
#endif

#if defined __UINT_LEAST16_MAX__ && __UINT_LEAST16_MAX__ <= __INT_MAX__
typedef __UINT_LEAST16_TYPE__ yytype_uint16;
#elif (!defined __UINT_LEAST16_MAX__ && defined YY_STDINT_H \
       && UINT_LEAST16_MAX <= INT_MAX)
typedef uint_least16_t yytype_uint16;
#elif !defined __UINT_LEAST16_MAX__ && USHRT_MAX <= INT_MAX
typedef unsigned short yytype_uint16;
#else
typedef int yytype_uint16;
#endif

#ifndef YYPTRDIFF_T
# if defined __PTRDIFF_TYPE__ && defined __PTRDIFF_MAX__
#  define YYPTRDIFF_T __PTRDIFF_TYPE__
#  define YYPTRDIFF_MAXIMUM __PTRDIFF_MAX__
# elif defined PTRDIFF_MAX
#  ifndef ptrdiff_t
#   include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  endif
#  define YYPTRDIFF_T ptrdiff_t
#  define YYPTRDIFF_MAXIMUM PTRDIFF_MAX
# else
#  define YYPTRDIFF_T long
#  define YYPTRDIFF_MAXIMUM LONG_MAX
# endif
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif defined __STDC_VERSION__ && 199901 <= __STDC_VERSION__
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned
# endif
#endif

#define YYSIZE_MAXIMUM                                  \
  YY_CAST (YYPTRDIFF_T,                                 \
           (YYPTRDIFF_MAXIMUM < YY_CAST (YYSIZE_T, -1)  \
            ? YYPTRDIFF_MAXIMUM                         \
            : YY_CAST (YYSIZE_T, -1)))

#define YYSIZEOF(X) YY_CAST (YYPTRDIFF_T, sizeof (X))


/* Stored state numbers (used for stacks). */
typedef yytype_int8 yy_state_t;

/* State numbers in computations.  */
typedef int yy_state_fast_t;

#ifndef YY_
# if defined YYENABLE_NLS && YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(Msgid) dgettext ("bison-runtime", Msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(Msgid) Msgid
# endif
#endif


#ifndef YY_ATTRIBUTE_PURE
# if defined __GNUC__ && 2 < __GNUC__ + (96 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_PURE __attribute__ ((__pure__))
# else
#  define YY_ATTRIBUTE_PURE
# endif
#endif

#ifndef YY_ATTRIBUTE_UNUSED
# if defined __GNUC__ && 2 < __GNUC__ + (7 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_UNUSED __attribute__ ((__unused__))
# else
#  define YY_ATTRIBUTE_UNUSED
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YY_USE(E) ((void) (E))
#else
# define YY_USE(E) /* empty */
#endif

/* Suppress an incorrect diagnostic about yylval being uninitialized.  */
#if defined __GNUC__ && ! defined __ICC && 406 <= __GNUC__ * 100 + __GNUC_MINOR__
# if __GNUC__ * 100 + __GNUC_MINOR__ < 407
#  define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN                           \
    _Pragma ("GCC diagnostic push")                                     \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")
# else
#  define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN                           \
    _Pragma ("GCC diagnostic push")                                     \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")              \
    _Pragma ("GCC diagnostic ignored \"-Wmaybe-uninitialized\"")
# endif
# define YY_IGNORE_MAYBE_UNINITIALIZED_END      \
    _Pragma ("GCC diagnostic pop")
#else
# define YY_INITIAL_VALUE(Value) Value
#endif
#ifndef YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_END
#endif
#ifndef YY_INITIAL_VALUE
# define YY_INITIAL_VALUE(Value) /* Nothing. */
#endif

#if defined __cplusplus && defined __GNUC__ && ! defined __ICC && 6 <= __GNUC__
# define YY_IGNORE_USELESS_CAST_BEGIN                          \
    _Pragma ("GCC diagnostic push")                            \
    _Pragma ("GCC diagnostic ignored \"-Wuseless-cast\"")
# define YY_IGNORE_USELESS_CAST_END            \
    _Pragma ("GCC diagnostic pop")
#endif
#ifndef YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_END
#endif


#define YY_ASSERT(E) ((void) (0 && (E)))

#if !defined yyoverflow

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined EXIT_SUCCESS
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
      /* Use EXIT_SUCCESS as a witness for stdlib.h.  */
#     ifndef EXIT_SUCCESS
#      define EXIT_SUCCESS 0
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's 'empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (0)
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined EXIT_SUCCESS \
       && ! ((defined YYMALLOC || defined malloc) \
             && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef EXIT_SUCCESS
#    define EXIT_SUCCESS 0
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined EXIT_SUCCESS
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined EXIT_SUCCESS
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* !defined yyoverflow */

#if (! defined yyoverflow \
     && (! defined __cplusplus \
         || (defined SPEF_STYPE_IS_TRIVIAL && SPEF_STYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yy_state_t yyss_alloc;
  YYSTYPE yyvs_alloc;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (YYSIZEOF (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (YYSIZEOF (yy_state_t) + YYSIZEOF (YYSTYPE)) \
      + YYSTACK_GAP_MAXIMUM)

# define YYCOPY_NEEDED 1

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack_alloc, Stack)                           \
    do                                                                  \
      {                                                                 \
        YYPTRDIFF_T yynewbytes;                                         \
        YYCOPY (&yyptr->Stack_alloc, Stack, yysize);                    \
        Stack = &yyptr->Stack_alloc;                                    \
        yynewbytes = yystacksize * YYSIZEOF (*Stack) + YYSTACK_GAP_MAXIMUM; \
        yyptr += yynewbytes / YYSIZEOF (*yyptr);                        \
      }                                                                 \
    while (0)

#endif

#if defined YYCOPY_NEEDED && YYCOPY_NEEDED
/* Copy COUNT objects from SRC to DST.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(Dst, Src, Count) \
      __builtin_memcpy (Dst, Src, YY_CAST (YYSIZE_T, (Count)) * sizeof (*(Src)))
#  else
#   define YYCOPY(Dst, Src, Count)              \
      do                                        \
        {                                       \
          YYPTRDIFF_T yyi;                      \
          for (yyi = 0; yyi < (Count); yyi++)   \
            (Dst)[yyi] = (Src)[yyi];            \
        }                                       \
      while (0)
#  endif
# endif
#endif /* !YYCOPY_NEEDED */

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  3
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   71

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  25
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  22
/* YYNRULES -- Number of rules.  */
#define YYNRULES  53
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  82

/* YYMAXUTOK -- Last valid token kind.  */
#define YYMAXUTOK   279


/* YYTRANSLATE(TOKEN-NUM) -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex, with out-of-bounds checking.  */
#define YYTRANSLATE(YYX)                                \
  (0 <= (YYX) && (YYX) <= YYMAXUTOK                     \
   ? YY_CAST (yysymbol_kind_t, yytranslate[YYX])        \
   : YYSYMBOL_YYUNDEF)

/* YYTRANSLATE[TOKEN-NUM] -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex.  */
static const yytype_int8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24
};

#if SPEF_DEBUG
/* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_uint8 yyrline[] =
{
       0,    35,    35,    38,    40,    44,    45,    46,    47,    48,
      49,    50,    51,    55,    56,    57,    58,    59,    60,    65,
      64,    77,    78,    82,    90,   101,   109,   122,   131,   138,
     146,   148,   152,   158,   163,   168,   174,   180,   185,   189,
     198,   209,   210,   214,   222,   230,   231,   232,   233,   237,
     238,   239,   240,   241
};
#endif

/** Accessing symbol of state STATE.  */
#define YY_ACCESSING_SYMBOL(State) YY_CAST (yysymbol_kind_t, yystos[State])

#if SPEF_DEBUG || 0
/* The user-facing name of the symbol whose (internal) number is
   YYSYMBOL.  No bounds checking.  */
static const char *yysymbol_name (yysymbol_kind_t yysymbol) YY_ATTRIBUTE_UNUSED;

/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "\"end of file\"", "error", "\"invalid token\"", "EOL", "K_NAME_MAP",
  "K_PORTS", "K_CONN", "K_CAP", "K_RES", "K_END", "K_D_NET", "K_COORD",
  "K_LOAD", "K_DRIVE", "K_LL", "K_UR", "K_LAYER", "K_IGNORE_ATTR",
  "HEADER_KEY", "CONN_TYPE", "DIRECTION", "NAME_REF", "SPEF_NAME",
  "QUOTED_STRING", "NUMBER", "$accept", "spef_file", "lines", "line",
  "section_line", "header_line", "$@1", "header_values", "header_value",
  "name_map_entry", "port_entry", "dnet_entry", "conn_entry", "conn_start",
  "conn_attrs", "conn_attr", "cap_res_entry", "direction_opt", "direction",
  "conn_type", "name_token", "name_value_token", YY_NULLPTR
};

static const char *
yysymbol_name (yysymbol_kind_t yysymbol)
{
  return yytname[yysymbol];
}
#endif

#define YYPACT_NINF (-19)

#define yypact_value_is_default(Yyn) \
  ((Yyn) == YYPACT_NINF)

#define YYTABLE_NINF (-1)

#define yytable_value_is_error(Yyn) \
  0

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
static const yytype_int8 yypact[] =
{
     -19,    26,    15,   -19,   -19,   -19,   -19,   -19,   -19,   -19,
     -19,     9,   -19,   -19,   -19,   -18,   -19,   -19,     9,   -19,
     -19,   -19,   -19,   -19,   -19,   -19,   -19,   -19,     9,    20,
     -19,    17,   -18,   -19,   -19,   -19,   -19,   -19,    39,    29,
      -2,    20,   -19,     5,    51,    24,   -19,   -19,   -19,    52,
      32,   -19,    33,    34,     9,    35,    36,    37,   -19,   -19,
     -19,   -19,   -19,    38,   -19,   -19,   -19,   -19,    60,    40,
     -19,   -19,    41,    42,   -19,    43,   -19,   -19,   -19,   -19,
      65,   -19
};

/* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
   Performed when YYTABLE does not specify something else to do.  Zero
   means the default is an error.  */
static const yytype_int8 yydefact[] =
{
       3,     0,     2,     1,     5,    13,    14,    15,    16,    17,
      18,     0,    19,    44,    48,     0,    46,    47,     0,     4,
       6,     7,     8,     9,    10,    11,    30,    12,     0,     0,
      45,     0,     0,    53,    49,    50,    51,    52,     0,     0,
       0,    41,    43,     0,     0,     0,    21,    23,    24,     0,
       0,    28,     0,     0,     0,     0,     0,     0,    38,    31,
      29,    42,    25,     0,    27,    20,    22,    39,     0,     0,
      33,    34,     0,     0,    37,     0,    40,    32,    35,    36,
       0,    26
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int8 yypgoto[] =
{
     -19,   -19,   -19,   -19,   -19,   -19,   -19,   -19,    25,   -19,
     -19,   -19,   -19,   -19,   -19,   -19,   -19,   -19,    28,   -19,
     -11,    56
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int8 yydefgoto[] =
{
       0,     1,     2,    19,    20,    21,    32,    45,    46,    22,
      23,    24,    25,    26,    40,    59,    27,    60,    43,    28,
      29,    47
};

/* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule whose
   number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int8 yytable[] =
{
      31,    51,    33,    34,    35,    36,    37,    39,    62,    52,
      53,    54,    55,    56,    57,    58,    63,    41,     4,     5,
       6,     7,     8,     9,    10,    11,     3,    65,    50,    14,
      30,    16,    17,    12,    13,    14,    15,    16,    17,    18,
      42,    44,    48,    71,    33,    34,    35,    36,    37,    14,
      30,    16,    17,    49,    64,    67,    68,    69,    70,    72,
      73,    74,    75,    76,    77,    78,    79,    80,    81,    61,
      66,    38
};

static const yytype_int8 yycheck[] =
{
      11,     3,    20,    21,    22,    23,    24,    18,     3,    11,
      12,    13,    14,    15,    16,    17,    11,    28,     3,     4,
       5,     6,     7,     8,     9,    10,     0,     3,    39,    20,
      21,    22,    23,    18,    19,    20,    21,    22,    23,    24,
      20,    24,     3,    54,    20,    21,    22,    23,    24,    20,
      21,    22,    23,    24,     3,     3,    24,    24,    24,    24,
      24,    24,    24,     3,    24,    24,    24,    24,     3,    41,
      45,    15
};

/* YYSTOS[STATE-NUM] -- The symbol kind of the accessing symbol of
   state STATE-NUM.  */
static const yytype_int8 yystos[] =
{
       0,    26,    27,     0,     3,     4,     5,     6,     7,     8,
       9,    10,    18,    19,    20,    21,    22,    23,    24,    28,
      29,    30,    34,    35,    36,    37,    38,    41,    44,    45,
      21,    45,    31,    20,    21,    22,    23,    24,    46,    45,
      39,    45,    20,    43,    24,    32,    33,    46,     3,    24,
      45,     3,    11,    12,    13,    14,    15,    16,    17,    40,
      42,    43,     3,    11,     3,     3,    33,     3,    24,    24,
      24,    45,    24,    24,    24,    24,     3,    24,    24,    24,
      24,     3
};

/* YYR1[RULE-NUM] -- Symbol kind of the left-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr1[] =
{
       0,    25,    26,    27,    27,    28,    28,    28,    28,    28,
      28,    28,    28,    29,    29,    29,    29,    29,    29,    31,
      30,    32,    32,    33,    34,    35,    35,    36,    37,    38,
      39,    39,    40,    40,    40,    40,    40,    40,    40,    41,
      41,    42,    42,    43,    44,    45,    45,    45,    45,    46,
      46,    46,    46,    46
};

/* YYR2[RULE-NUM] -- Number of symbols on the right-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr2[] =
{
       0,     2,     1,     0,     2,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     0,
       4,     1,     2,     1,     3,     3,     6,     4,     3,     3,
       0,     2,     3,     2,     2,     3,     3,     2,     1,     4,
       5,     0,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1
};


enum { YYENOMEM = -2 };

#define yyerrok         (yyerrstatus = 0)
#define yyclearin       (yychar = SPEF_EMPTY)

#define YYACCEPT        goto yyacceptlab
#define YYABORT         goto yyabortlab
#define YYERROR         goto yyerrorlab
#define YYNOMEM         goto yyexhaustedlab


#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)                                    \
  do                                                              \
    if (yychar == SPEF_EMPTY)                                        \
      {                                                           \
        yychar = (Token);                                         \
        yylval = (Value);                                         \
        YYPOPSTACK (yylen);                                       \
        yystate = *yyssp;                                         \
        goto yybackup;                                            \
      }                                                           \
    else                                                          \
      {                                                           \
        yyerror (context, YY_("syntax error: cannot back up")); \
        YYERROR;                                                  \
      }                                                           \
  while (0)

/* Backward compatibility with an undocumented macro.
   Use SPEF_error or SPEF_UNDEF. */
#define YYERRCODE SPEF_UNDEF


/* Enable debugging if requested.  */
#if SPEF_DEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)                        \
do {                                            \
  if (yydebug)                                  \
    YYFPRINTF Args;                             \
} while (0)




# define YY_SYMBOL_PRINT(Title, Kind, Value, Location)                    \
do {                                                                      \
  if (yydebug)                                                            \
    {                                                                     \
      YYFPRINTF (stderr, "%s ", Title);                                   \
      yy_symbol_print (stderr,                                            \
                  Kind, Value, context); \
      YYFPRINTF (stderr, "\n");                                           \
    }                                                                     \
} while (0)


/*-----------------------------------.
| Print this symbol's value on YYO.  |
`-----------------------------------*/

static void
yy_symbol_value_print (FILE *yyo,
                       yysymbol_kind_t yykind, YYSTYPE const * const yyvaluep, spef::ParserContext* context)
{
  FILE *yyoutput = yyo;
  YY_USE (yyoutput);
  YY_USE (context);
  if (!yyvaluep)
    return;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YY_USE (yykind);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}


/*---------------------------.
| Print this symbol on YYO.  |
`---------------------------*/

static void
yy_symbol_print (FILE *yyo,
                 yysymbol_kind_t yykind, YYSTYPE const * const yyvaluep, spef::ParserContext* context)
{
  YYFPRINTF (yyo, "%s %s (",
             yykind < YYNTOKENS ? "token" : "nterm", yysymbol_name (yykind));

  yy_symbol_value_print (yyo, yykind, yyvaluep, context);
  YYFPRINTF (yyo, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

static void
yy_stack_print (yy_state_t *yybottom, yy_state_t *yytop)
{
  YYFPRINTF (stderr, "Stack now");
  for (; yybottom <= yytop; yybottom++)
    {
      int yybot = *yybottom;
      YYFPRINTF (stderr, " %d", yybot);
    }
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)                            \
do {                                                            \
  if (yydebug)                                                  \
    yy_stack_print ((Bottom), (Top));                           \
} while (0)


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

static void
yy_reduce_print (yy_state_t *yyssp, YYSTYPE *yyvsp,
                 int yyrule, spef::ParserContext* context)
{
  int yylno = yyrline[yyrule];
  int yynrhs = yyr2[yyrule];
  int yyi;
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %d):\n",
             yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      YYFPRINTF (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr,
                       YY_ACCESSING_SYMBOL (+yyssp[yyi + 1 - yynrhs]),
                       &yyvsp[(yyi + 1) - (yynrhs)], context);
      YYFPRINTF (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)          \
do {                                    \
  if (yydebug)                          \
    yy_reduce_print (yyssp, yyvsp, Rule, context); \
} while (0)

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !SPEF_DEBUG */
# define YYDPRINTF(Args) ((void) 0)
# define YY_SYMBOL_PRINT(Title, Kind, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !SPEF_DEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif






/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

static void
yydestruct (const char *yymsg,
            yysymbol_kind_t yykind, YYSTYPE *yyvaluep, spef::ParserContext* context)
{
  YY_USE (yyvaluep);
  YY_USE (context);
  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yykind, yyvaluep, yylocationp);

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  switch (yykind)
    {
    case YYSYMBOL_HEADER_KEY: /* HEADER_KEY  */
#line 28 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
            { std::free(((*yyvaluep).str)); }
#line 904 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
        break;

    case YYSYMBOL_CONN_TYPE: /* CONN_TYPE  */
#line 28 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
            { std::free(((*yyvaluep).str)); }
#line 910 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
        break;

    case YYSYMBOL_DIRECTION: /* DIRECTION  */
#line 28 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
            { std::free(((*yyvaluep).str)); }
#line 916 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
        break;

    case YYSYMBOL_NAME_REF: /* NAME_REF  */
#line 28 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
            { std::free(((*yyvaluep).str)); }
#line 922 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
        break;

    case YYSYMBOL_SPEF_NAME: /* SPEF_NAME  */
#line 28 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
            { std::free(((*yyvaluep).str)); }
#line 928 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
        break;

    case YYSYMBOL_QUOTED_STRING: /* QUOTED_STRING  */
#line 28 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
            { std::free(((*yyvaluep).str)); }
#line 934 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
        break;

    case YYSYMBOL_NUMBER: /* NUMBER  */
#line 28 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
            { std::free(((*yyvaluep).str)); }
#line 940 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
        break;

    case YYSYMBOL_name_token: /* name_token  */
#line 28 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
            { std::free(((*yyvaluep).str)); }
#line 946 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
        break;

    case YYSYMBOL_name_value_token: /* name_value_token  */
#line 28 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
            { std::free(((*yyvaluep).str)); }
#line 952 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
        break;

      default:
        break;
    }
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}


/* Lookahead token kind.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;
/* Number of syntax errors so far.  */
int yynerrs;




/*----------.
| yyparse.  |
`----------*/

int
yyparse (spef::ParserContext* context)
{
    yy_state_fast_t yystate = 0;
    /* Number of tokens to shift before error messages enabled.  */
    int yyerrstatus = 0;

    /* Refer to the stacks through separate pointers, to allow yyoverflow
       to reallocate them elsewhere.  */

    /* Their size.  */
    YYPTRDIFF_T yystacksize = YYINITDEPTH;

    /* The state stack: array, bottom, top.  */
    yy_state_t yyssa[YYINITDEPTH];
    yy_state_t *yyss = yyssa;
    yy_state_t *yyssp = yyss;

    /* The semantic value stack: array, bottom, top.  */
    YYSTYPE yyvsa[YYINITDEPTH];
    YYSTYPE *yyvs = yyvsa;
    YYSTYPE *yyvsp = yyvs;

  int yyn;
  /* The return value of yyparse.  */
  int yyresult;
  /* Lookahead symbol kind.  */
  yysymbol_kind_t yytoken = YYSYMBOL_YYEMPTY;
  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;



#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N))

  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yychar = SPEF_EMPTY; /* Cause a token to be read.  */

  goto yysetstate;


/*------------------------------------------------------------.
| yynewstate -- push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;


/*--------------------------------------------------------------------.
| yysetstate -- set current state (the top of the stack) to yystate.  |
`--------------------------------------------------------------------*/
yysetstate:
  YYDPRINTF ((stderr, "Entering state %d\n", yystate));
  YY_ASSERT (0 <= yystate && yystate < YYNSTATES);
  YY_IGNORE_USELESS_CAST_BEGIN
  *yyssp = YY_CAST (yy_state_t, yystate);
  YY_IGNORE_USELESS_CAST_END
  YY_STACK_PRINT (yyss, yyssp);

  if (yyss + yystacksize - 1 <= yyssp)
#if !defined yyoverflow && !defined YYSTACK_RELOCATE
    YYNOMEM;
#else
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYPTRDIFF_T yysize = yyssp - yyss + 1;

# if defined yyoverflow
      {
        /* Give user a chance to reallocate the stack.  Use copies of
           these so that the &'s don't force the real ones into
           memory.  */
        yy_state_t *yyss1 = yyss;
        YYSTYPE *yyvs1 = yyvs;

        /* Each stack pointer address is followed by the size of the
           data in use in that stack, in bytes.  This used to be a
           conditional around just the two extra args, but that might
           be undefined if yyoverflow is a macro.  */
        yyoverflow (YY_("memory exhausted"),
                    &yyss1, yysize * YYSIZEOF (*yyssp),
                    &yyvs1, yysize * YYSIZEOF (*yyvsp),
                    &yystacksize);
        yyss = yyss1;
        yyvs = yyvs1;
      }
# else /* defined YYSTACK_RELOCATE */
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
        YYNOMEM;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
        yystacksize = YYMAXDEPTH;

      {
        yy_state_t *yyss1 = yyss;
        union yyalloc *yyptr =
          YY_CAST (union yyalloc *,
                   YYSTACK_ALLOC (YY_CAST (YYSIZE_T, YYSTACK_BYTES (yystacksize))));
        if (! yyptr)
          YYNOMEM;
        YYSTACK_RELOCATE (yyss_alloc, yyss);
        YYSTACK_RELOCATE (yyvs_alloc, yyvs);
#  undef YYSTACK_RELOCATE
        if (yyss1 != yyssa)
          YYSTACK_FREE (yyss1);
      }
# endif

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;

      YY_IGNORE_USELESS_CAST_BEGIN
      YYDPRINTF ((stderr, "Stack size increased to %ld\n",
                  YY_CAST (long, yystacksize)));
      YY_IGNORE_USELESS_CAST_END

      if (yyss + yystacksize - 1 <= yyssp)
        YYABORT;
    }
#endif /* !defined yyoverflow && !defined YYSTACK_RELOCATE */


  if (yystate == YYFINAL)
    YYACCEPT;

  goto yybackup;


/*-----------.
| yybackup.  |
`-----------*/
yybackup:
  /* Do appropriate processing given the current state.  Read a
     lookahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to lookahead token.  */
  yyn = yypact[yystate];
  if (yypact_value_is_default (yyn))
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* YYCHAR is either empty, or end-of-input, or a valid lookahead.  */
  if (yychar == SPEF_EMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token\n"));
      yychar = yylex ();
    }

  if (yychar <= SPEF_EOF)
    {
      yychar = SPEF_EOF;
      yytoken = YYSYMBOL_YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else if (yychar == SPEF_error)
    {
      /* The scanner already issued an error message, process directly
         to error recovery.  But do not keep the error token as
         lookahead, it is too special and may lead us to an endless
         loop in error recovery. */
      yychar = SPEF_UNDEF;
      yytoken = YYSYMBOL_YYerror;
      goto yyerrlab1;
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yytable_value_is_error (yyn))
        goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the lookahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);
  yystate = yyn;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END

  /* Discard the shifted token.  */
  yychar = SPEF_EMPTY;
  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     '$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
  case 13: /* section_line: K_NAME_MAP  */
#line 55 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
               { context->setSection(spef::SectionType::kNameMap); }
#line 1222 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
    break;

  case 14: /* section_line: K_PORTS  */
#line 56 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
            { context->setSection(spef::SectionType::kPorts); }
#line 1228 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
    break;

  case 15: /* section_line: K_CONN  */
#line 57 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
           { context->setSection(spef::SectionType::kConn); }
#line 1234 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
    break;

  case 16: /* section_line: K_CAP  */
#line 58 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
          { context->setSection(spef::SectionType::kCap); }
#line 1240 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
    break;

  case 17: /* section_line: K_RES  */
#line 59 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
          { context->setSection(spef::SectionType::kRes); }
#line 1246 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
    break;

  case 18: /* section_line: K_END  */
#line 60 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
          { context->setSection(spef::SectionType::kEnd); }
#line 1252 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
    break;

  case 19: /* $@1: %empty  */
#line 65 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
    {
      context->startHeader(spef::tokenToString((yyvsp[0].str)));
      std::free((yyvsp[0].str));
    }
#line 1261 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
    break;

  case 20: /* header_line: HEADER_KEY $@1 header_values EOL  */
#line 71 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
    {
      context->finishHeader();
    }
#line 1269 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
    break;

  case 23: /* header_value: name_value_token  */
#line 83 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
    {
      context->addHeaderValue(spef::stripQuotes(spef::tokenToString((yyvsp[0].str))));
      std::free((yyvsp[0].str));
    }
#line 1278 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
    break;

  case 24: /* name_map_entry: NAME_REF name_value_token EOL  */
#line 91 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
    {
      if (context->section() == spef::SectionType::kNameMap) {
        context->addNameMap(spef::tokenToString((yyvsp[-2].str)), spef::stripQuotes(spef::tokenToString((yyvsp[-1].str))));
      }
      std::free((yyvsp[-2].str));
      std::free((yyvsp[-1].str));
    }
#line 1290 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
    break;

  case 25: /* port_entry: name_token direction EOL  */
#line 102 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
    {
      if (context->section() == spef::SectionType::kPorts) {
        context->addPort(spef::tokenToString((yyvsp[-2].str)), static_cast<spef::ConnectionDirection>((yyvsp[-1].ival)),
                         spef::Coord{});
      }
      std::free((yyvsp[-2].str));
    }
#line 1302 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
    break;

  case 26: /* port_entry: name_token direction K_COORD NUMBER NUMBER EOL  */
#line 110 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
    {
      if (context->section() == spef::SectionType::kPorts) {
        context->addPort(spef::tokenToString((yyvsp[-5].str)), static_cast<spef::ConnectionDirection>((yyvsp[-4].ival)),
                         spef::Coord{spef::toDouble((yyvsp[-2].str)), spef::toDouble((yyvsp[-1].str))});
      }
      std::free((yyvsp[-5].str));
      std::free((yyvsp[-2].str));
      std::free((yyvsp[-1].str));
    }
#line 1316 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
    break;

  case 27: /* dnet_entry: K_D_NET name_token NUMBER EOL  */
#line 123 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
    {
      context->startNet(spef::tokenToString((yyvsp[-2].str)), spef::toDouble((yyvsp[-1].str)), 0);
      std::free((yyvsp[-2].str));
      std::free((yyvsp[-1].str));
    }
#line 1326 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
    break;

  case 28: /* conn_entry: conn_start conn_attrs EOL  */
#line 132 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
    {
      context->finishConn();
    }
#line 1334 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
    break;

  case 29: /* conn_start: conn_type name_token direction_opt  */
#line 139 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
    {
      context->startConn(static_cast<spef::ConnectionType>((yyvsp[-2].ival)), spef::tokenToString((yyvsp[-1].str)),
                         static_cast<spef::ConnectionDirection>((yyvsp[0].ival)));
      std::free((yyvsp[-1].str));
    }
#line 1344 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
    break;

  case 32: /* conn_attr: K_COORD NUMBER NUMBER  */
#line 153 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
    {
      context->setConnCoordinate(spef::Coord{spef::toDouble((yyvsp[-1].str)), spef::toDouble((yyvsp[0].str))});
      std::free((yyvsp[-1].str));
      std::free((yyvsp[0].str));
    }
#line 1354 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
    break;

  case 33: /* conn_attr: K_LOAD NUMBER  */
#line 159 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
    {
      context->setConnLoad(spef::toDouble((yyvsp[0].str)));
      std::free((yyvsp[0].str));
    }
#line 1363 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
    break;

  case 34: /* conn_attr: K_DRIVE name_token  */
#line 164 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
    {
      context->setConnDrivingCell(spef::stripQuotes(spef::tokenToString((yyvsp[0].str))));
      std::free((yyvsp[0].str));
    }
#line 1372 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
    break;

  case 35: /* conn_attr: K_LL NUMBER NUMBER  */
#line 169 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
    {
      context->setConnLowerLeft(spef::Coord{spef::toDouble((yyvsp[-1].str)), spef::toDouble((yyvsp[0].str))});
      std::free((yyvsp[-1].str));
      std::free((yyvsp[0].str));
    }
#line 1382 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
    break;

  case 36: /* conn_attr: K_UR NUMBER NUMBER  */
#line 175 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
    {
      context->setConnUpperRight(spef::Coord{spef::toDouble((yyvsp[-1].str)), spef::toDouble((yyvsp[0].str))});
      std::free((yyvsp[-1].str));
      std::free((yyvsp[0].str));
    }
#line 1392 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
    break;

  case 37: /* conn_attr: K_LAYER NUMBER  */
#line 181 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
    {
      context->setConnLayer(spef::toInt((yyvsp[0].str)));
      std::free((yyvsp[0].str));
    }
#line 1401 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
    break;

  case 39: /* cap_res_entry: NUMBER name_token NUMBER EOL  */
#line 190 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
    {
      if (context->section() == spef::SectionType::kCap) {
        context->addCap(spef::tokenToString((yyvsp[-2].str)), "", spef::toDouble((yyvsp[-1].str)));
      }
      std::free((yyvsp[-3].str));
      std::free((yyvsp[-2].str));
      std::free((yyvsp[-1].str));
    }
#line 1414 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
    break;

  case 40: /* cap_res_entry: NUMBER name_token name_token NUMBER EOL  */
#line 199 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
    {
      context->addCapOrRes(spef::tokenToString((yyvsp[-3].str)), spef::tokenToString((yyvsp[-2].str)), spef::toDouble((yyvsp[-1].str)));
      std::free((yyvsp[-4].str));
      std::free((yyvsp[-3].str));
      std::free((yyvsp[-2].str));
      std::free((yyvsp[-1].str));
    }
#line 1426 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
    break;

  case 41: /* direction_opt: %empty  */
#line 209 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
                { (yyval.ival) = static_cast<int>(spef::ConnectionDirection::kUninitialized); }
#line 1432 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
    break;

  case 42: /* direction_opt: direction  */
#line 210 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
              { (yyval.ival) = (yyvsp[0].ival); }
#line 1438 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
    break;

  case 43: /* direction: DIRECTION  */
#line 215 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
    {
      (yyval.ival) = static_cast<int>(spef::parseDirection((yyvsp[0].str)));
      std::free((yyvsp[0].str));
    }
#line 1447 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
    break;

  case 44: /* conn_type: CONN_TYPE  */
#line 223 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
    {
      (yyval.ival) = static_cast<int>(spef::parseConnectionType((yyvsp[0].str)));
      std::free((yyvsp[0].str));
    }
#line 1456 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
    break;

  case 45: /* name_token: NAME_REF  */
#line 230 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
             { (yyval.str) = (yyvsp[0].str); }
#line 1462 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
    break;

  case 46: /* name_token: SPEF_NAME  */
#line 231 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
              { (yyval.str) = (yyvsp[0].str); }
#line 1468 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
    break;

  case 47: /* name_token: QUOTED_STRING  */
#line 232 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
                  { (yyval.str) = (yyvsp[0].str); }
#line 1474 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
    break;

  case 48: /* name_token: DIRECTION  */
#line 233 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
              { (yyval.str) = (yyvsp[0].str); }
#line 1480 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
    break;

  case 49: /* name_value_token: NAME_REF  */
#line 237 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
             { (yyval.str) = (yyvsp[0].str); }
#line 1486 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
    break;

  case 50: /* name_value_token: SPEF_NAME  */
#line 238 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
              { (yyval.str) = (yyvsp[0].str); }
#line 1492 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
    break;

  case 51: /* name_value_token: QUOTED_STRING  */
#line 239 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
                  { (yyval.str) = (yyvsp[0].str); }
#line 1498 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
    break;

  case 52: /* name_value_token: NUMBER  */
#line 240 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
           { (yyval.str) = (yyvsp[0].str); }
#line 1504 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
    break;

  case 53: /* name_value_token: DIRECTION  */
#line 241 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"
              { (yyval.str) = (yyvsp[0].str); }
#line 1510 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"
    break;


#line 1514 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/spef_parser/generated/spef_parser.cpp"

      default: break;
    }
  /* User semantic actions sometimes alter yychar, and that requires
     that yytoken be updated with the new translation.  We take the
     approach of translating immediately before every use of yytoken.
     One alternative is translating here after every semantic action,
     but that translation would be missed if the semantic action invokes
     YYABORT, YYACCEPT, or YYERROR immediately after altering yychar or
     if it invokes YYBACKUP.  In the case of YYABORT or YYACCEPT, an
     incorrect destructor might then be invoked immediately.  In the
     case of YYERROR or YYBACKUP, subsequent parser actions might lead
     to an incorrect destructor call or verbose syntax error message
     before the lookahead is translated.  */
  YY_SYMBOL_PRINT ("-> $$ =", YY_CAST (yysymbol_kind_t, yyr1[yyn]), &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;

  *++yyvsp = yyval;

  /* Now 'shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */
  {
    const int yylhs = yyr1[yyn] - YYNTOKENS;
    const int yyi = yypgoto[yylhs] + *yyssp;
    yystate = (0 <= yyi && yyi <= YYLAST && yycheck[yyi] == *yyssp
               ? yytable[yyi]
               : yydefgoto[yylhs]);
  }

  goto yynewstate;


/*--------------------------------------.
| yyerrlab -- here on detecting error.  |
`--------------------------------------*/
yyerrlab:
  /* Make sure we have latest lookahead translation.  See comments at
     user semantic actions for why this is necessary.  */
  yytoken = yychar == SPEF_EMPTY ? YYSYMBOL_YYEMPTY : YYTRANSLATE (yychar);
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
      yyerror (context, YY_("syntax error"));
    }

  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
         error, discard it.  */

      if (yychar <= SPEF_EOF)
        {
          /* Return failure if at end of input.  */
          if (yychar == SPEF_EOF)
            YYABORT;
        }
      else
        {
          yydestruct ("Error: discarding",
                      yytoken, &yylval, context);
          yychar = SPEF_EMPTY;
        }
    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:
  /* Pacify compilers when the user code never invokes YYERROR and the
     label yyerrorlab therefore never appears in user code.  */
  if (0)
    YYERROR;
  ++yynerrs;

  /* Do not reclaim the symbols of the rule whose action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;      /* Each real token shifted decrements this.  */

  /* Pop stack until we find a state that shifts the error token.  */
  for (;;)
    {
      yyn = yypact[yystate];
      if (!yypact_value_is_default (yyn))
        {
          yyn += YYSYMBOL_YYerror;
          if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYSYMBOL_YYerror)
            {
              yyn = yytable[yyn];
              if (0 < yyn)
                break;
            }
        }

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
        YYABORT;


      yydestruct ("Error: popping",
                  YY_ACCESSING_SYMBOL (yystate), yyvsp, context);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END


  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", YY_ACCESSING_SYMBOL (yyn), yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturnlab;


/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturnlab;


/*-----------------------------------------------------------.
| yyexhaustedlab -- YYNOMEM (memory exhaustion) comes here.  |
`-----------------------------------------------------------*/
yyexhaustedlab:
  yyerror (context, YY_("memory exhausted"));
  yyresult = 2;
  goto yyreturnlab;


/*----------------------------------------------------------.
| yyreturnlab -- parsing is finished, clean up and return.  |
`----------------------------------------------------------*/
yyreturnlab:
  if (yychar != SPEF_EMPTY)
    {
      /* Make sure we have latest lookahead translation.  See comments at
         user semantic actions for why this is necessary.  */
      yytoken = YYTRANSLATE (yychar);
      yydestruct ("Cleanup: discarding lookahead",
                  yytoken, &yylval, context);
    }
  /* Do not reclaim the symbols of the rule whose action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
                  YY_ACCESSING_SYMBOL (+*yyssp), yyvsp, context);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif

  return yyresult;
}

#line 244 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/spef_parser/spef_parser.yy"


void spef_error(spef::ParserContext* context, const char* message)
{
  if (context != nullptr) {
    context->setError(message == nullptr ? "parse error" : message);
  }
}
