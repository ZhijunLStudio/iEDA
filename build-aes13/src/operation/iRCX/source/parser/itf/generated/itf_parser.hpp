/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

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

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_ITF_HOME_LXQ_AIEDA_IEDA_AI_BUILD_AES13_SRC_OPERATION_IRCX_SOURCE_PARSER_ITF_GENERATED_ITF_PARSER_HPP_INCLUDED
# define YY_ITF_HOME_LXQ_AIEDA_IEDA_AI_BUILD_AES13_SRC_OPERATION_IRCX_SOURCE_PARSER_ITF_GENERATED_ITF_PARSER_HPP_INCLUDED
/* Debug traces.  */
#ifndef ITF_DEBUG
# if defined YYDEBUG
#if YYDEBUG
#   define ITF_DEBUG 1
#  else
#   define ITF_DEBUG 0
#  endif
# else /* ! defined YYDEBUG */
#  define ITF_DEBUG 0
# endif /* ! defined YYDEBUG */
#endif  /* ! defined ITF_DEBUG */
#if ITF_DEBUG
extern int itf_debug;
#endif
/* "%code requires" blocks.  */
#line 17 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"


#include <string.h>

#include <iostream>
#include <string>
#include <vector>

#include "itfrData.hpp"
#include "itfMarco.h"
#include "itfrSettings.hpp"
#include "itfrCallBacks.hpp"


#line 72 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.hpp"

/* Token kinds.  */
#ifndef ITF_TOKENTYPE
# define ITF_TOKENTYPE
  enum itf_tokentype
  {
    ITF_EMPTY = -2,
    ITF_EOF = 0,                   /* "end of file"  */
    ITF_error = 256,               /* error  */
    ITF_UNDEF = 257,               /* "invalid token"  */
    K_TECHNOLOGY = 258,            /* K_TECHNOLOGY  */
    K_PROCESS_FOUNDRY = 259,       /* K_PROCESS_FOUNDRY  */
    K_GLOBAL_TEMPERATURE = 260,    /* K_GLOBAL_TEMPERATURE  */
    K_BACKGROUND_ER = 261,         /* K_BACKGROUND_ER  */
    K_HALF_NODE_SCALE_FACTOR = 262, /* K_HALF_NODE_SCALE_FACTOR  */
    K_PROCESS_NODE = 263,          /* K_PROCESS_NODE  */
    K_PROCESS_TYPE = 264,          /* K_PROCESS_TYPE  */
    K_PROCESS_VERSION = 265,       /* K_PROCESS_VERSION  */
    K_PROCESS_CORNER = 266,        /* K_PROCESS_CORNER  */
    K_REFERENCE_DIRECTION = 267,   /* K_REFERENCE_DIRECTION  */
    K_USE_SI_DENSITY = 268,        /* K_USE_SI_DENSITY  */
    K_YES = 269,                   /* K_YES  */
    K_NO = 270,                    /* K_NO  */
    K_DROP_FACTOR_LATERAL_SPACING = 271, /* K_DROP_FACTOR_LATERAL_SPACING  */
    K_DIELECTRIC = 272,            /* K_DIELECTRIC  */
    K_DIELECTRIC_LAYER = 273,      /* K_DIELECTRIC_LAYER  */
    K_ER = 274,                    /* K_ER  */
    K_THICKNESS = 275,             /* K_THICKNESS  */
    K_MEASURED_FROM = 276,         /* K_MEASURED_FROM  */
    K_TOP_OF_CHIP = 277,           /* K_TOP_OF_CHIP  */
    K_SW_T = 278,                  /* K_SW_T  */
    K_TW_T = 279,                  /* K_TW_T  */
    K_ASSOCIATED_CONDUCTOR = 280,  /* K_ASSOCIATED_CONDUCTOR  */
    K_IS_CONFORMAL = 281,          /* K_IS_CONFORMAL  */
    K_DAMAGE_THICKNESS = 282,      /* K_DAMAGE_THICKNESS  */
    K_DAMAGE_ER = 283,             /* K_DAMAGE_ER  */
    K_CONDUCTOR = 284,             /* K_CONDUCTOR  */
    K_IS_PLANAR = 285,             /* K_IS_PLANAR  */
    K_WMIN = 286,                  /* K_WMIN  */
    K_SMIN = 287,                  /* K_SMIN  */
    K_AIR_GAP_VS_SPACING = 288,    /* K_AIR_GAP_VS_SPACING  */
    K_SPACINGS = 289,              /* K_SPACINGS  */
    K_AIR_GAP_WIDTHS = 290,        /* K_AIR_GAP_WIDTHS  */
    K_AIR_GAP_THICKNESSES = 291,   /* K_AIR_GAP_THICKNESSES  */
    K_AIR_GAP_BOTTOM_HEIGHTS = 292, /* K_AIR_GAP_BOTTOM_HEIGHTS  */
    K_BOTTOM_DIELECTRIC_THICKNESS = 293, /* K_BOTTOM_DIELECTRIC_THICKNESS  */
    K_BOTTOM_DIELECTRIC_ER = 294,  /* K_BOTTOM_DIELECTRIC_ER  */
    K_BOTTOM_THICKNESS_VS_SI_WIDTH = 295, /* K_BOTTOM_THICKNESS_VS_SI_WIDTH  */
    K_RESISTIVE_ONLY = 296,        /* K_RESISTIVE_ONLY  */
    K_CAPACITIVE_ONLY = 297,       /* K_CAPACITIVE_ONLY  */
    K_T0 = 298,                    /* K_T0  */
    K_CRT1 = 299,                  /* K_CRT1  */
    K_CRT2 = 300,                  /* K_CRT2  */
    K_DROP_FACTOR = 301,           /* K_DROP_FACTOR  */
    K_ETCH = 302,                  /* K_ETCH  */
    K_CAPACITIVE_ONLY_ETCH = 303,  /* K_CAPACITIVE_ONLY_ETCH  */
    K_RESISTIVE_ONLY_ETCH = 304,   /* K_RESISTIVE_ONLY_ETCH  */
    K_ETCH_VS_WIDTH_AND_SPACING = 305, /* K_ETCH_VS_WIDTH_AND_SPACING  */
    K_WIDTHS = 306,                /* K_WIDTHS  */
    K_VALUES = 307,                /* K_VALUES  */
    K_ETCH_FROM_TOP = 308,         /* K_ETCH_FROM_TOP  */
    K_FILL_RATIO = 309,            /* K_FILL_RATIO  */
    K_FILL_SPACING = 310,          /* K_FILL_SPACING  */
    K_FILL_WIDTH = 311,            /* K_FILL_WIDTH  */
    K_FILL_TYPE = 312,             /* K_FILL_TYPE  */
    K_GROUNDED = 313,              /* K_GROUNDED  */
    K_FLOATING = 314,              /* K_FLOATING  */
    K_GATE_TO_CONTACT_SMIN = 315,  /* K_GATE_TO_CONTACT_SMIN  */
    K_GATE_TO_DIFFUSION_CAP = 316, /* K_GATE_TO_DIFFUSION_CAP  */
    K_NUMBER_OF_TABLES = 317,      /* K_NUMBER_OF_TABLES  */
    K_CONTACT_TO_CONTACT_SPACINGS = 318, /* K_CONTACT_TO_CONTACT_SPACINGS  */
    K_GATE_TO_CONTACT_SPACINGS = 319, /* K_GATE_TO_CONTACT_SPACINGS  */
    K_CAPS_PER_MICRON = 320,       /* K_CAPS_PER_MICRON  */
    K_THICKNESS_CHANGES = 321,     /* K_THICKNESS_CHANGES  */
    K_LAYER_TYPE = 322,            /* K_LAYER_TYPE  */
    K_POLYNOMIAL_BASED_THICKNESS_VARIATION = 323, /* K_POLYNOMIAL_BASED_THICKNESS_VARIATION  */
    K_DENSITY_POLYNOMIAL_ORDERS = 324, /* K_DENSITY_POLYNOMIAL_ORDERS  */
    K_WIDTH_POLYNOMIAL_ORDERS = 325, /* K_WIDTH_POLYNOMIAL_ORDERS  */
    K_WIDTH_RANGES = 326,          /* K_WIDTH_RANGES  */
    K_POLYNOMIAL_COEFFICIENTS = 327, /* K_POLYNOMIAL_COEFFICIENTS  */
    K_RPSQ = 328,                  /* K_RPSQ  */
    K_RHO = 329,                   /* K_RHO  */
    K_RPSQ_VS_SI_WIDTH = 330,      /* K_RPSQ_VS_SI_WIDTH  */
    K_RPSQ_VS_WIDTH_AND_SPACING = 331, /* K_RPSQ_VS_WIDTH_AND_SPACING  */
    K_WIDTH = 332,                 /* K_WIDTH  */
    K_SIDE_TANGENT = 333,          /* K_SIDE_TANGENT  */
    K_THICKNESS_VS_DENSITY = 334,  /* K_THICKNESS_VS_DENSITY  */
    K_THICKNESS_VS_WIDTH_AND_SPACING = 335, /* K_THICKNESS_VS_WIDTH_AND_SPACING  */
    K_TVF_ADJUSTMENT_TABLES = 336, /* K_TVF_ADJUSTMENT_TABLES  */
    K_BOTTOM_THICKNESS_VS_WIDTH_AND_SPACING = 337, /* K_BOTTOM_THICKNESS_VS_WIDTH_AND_SPACING  */
    K_BOTTOM_THICKNESS_VS_WIDTH_AND_DELTAPD = 338, /* K_BOTTOM_THICKNESS_VS_WIDTH_AND_DELTAPD  */
    K_VIA = 339,                   /* K_VIA  */
    K_FROM = 340,                  /* K_FROM  */
    K_TO = 341,                    /* K_TO  */
    K_CRT_VS_AREA = 342,           /* K_CRT_VS_AREA  */
    K_RPV = 343,                   /* K_RPV  */
    K_AREA = 344,                  /* K_AREA  */
    K_RPV_VS_AREA = 345,           /* K_RPV_VS_AREA  */
    K_ETCH_VS_WIDTH_AND_LENGTH = 346, /* K_ETCH_VS_WIDTH_AND_LENGTH  */
    K_VARIATION_PARAMETERS = 347,  /* K_VARIATION_PARAMETERS  */
    K_DENSITY_BOX_WEIGHTING_FACTOR = 348, /* K_DENSITY_BOX_WEIGHTING_FACTOR  */
    K_ILD_VS_WIDTH_AND_SPACING = 349, /* K_ILD_VS_WIDTH_AND_SPACING  */
    K_DELTAPD = 350,               /* K_DELTAPD  */
    K_LENGTHS = 351,               /* K_LENGTHS  */
    K_RHO_VS_SI_WIDTH_AND_THICKNESS = 352, /* K_RHO_VS_SI_WIDTH_AND_THICKNESS  */
    K_RHO_VS_WIDTH_AND_SPACING = 353, /* K_RHO_VS_WIDTH_AND_SPACING  */
    K_ETCH_VS_CONTACT_AND_GATE_SPACINGS = 354, /* K_ETCH_VS_CONTACT_AND_GATE_SPACINGS  */
    K_CRT_VS_SI_WIDTH = 355,       /* K_CRT_VS_SI_WIDTH  */
    K_DENSITY_BOUNDS_VS_WIDTH = 356, /* K_DENSITY_BOUNDS_VS_WIDTH  */
    K_THICKNESS_BOUNDS = 357,      /* K_THICKNESS_BOUNDS  */
    K_DEVICE_TYPE = 358,           /* K_DEVICE_TYPE  */
    K_PARALLEL_TO_REFERENCE = 359, /* K_PARALLEL_TO_REFERENCE  */
    K_PERPENDICULAR_TO_REFERENCE = 360, /* K_PERPENDICULAR_TO_REFERENCE  */
    K_PARALLEL_TO_GATE = 361,      /* K_PARALLEL_TO_GATE  */
    K_BW_T = 362,                  /* K_BW_T  */
    K_LINKED_TO = 363,             /* K_LINKED_TO  */
    K_EXTENSIONMIN = 364,          /* K_EXTENSIONMIN  */
    K_RAISED_DIFFUSION_THICKNESS = 365, /* K_RAISED_DIFFUSION_THICKNESS  */
    K_RAISED_DIFFUSION_TO_GATE_SMIN = 366, /* K_RAISED_DIFFUSION_TO_GATE_SMIN  */
    K_MULTIGATE = 367,             /* K_MULTIGATE  */
    K_FIN_SPACING = 368,           /* K_FIN_SPACING  */
    K_FIN_WIDTH = 369,             /* K_FIN_WIDTH  */
    K_FIN_LENGTH = 370,            /* K_FIN_LENGTH  */
    K_FIN_THICKNESS = 371,         /* K_FIN_THICKNESS  */
    K_GATE_OXIDE_TOP_T = 372,      /* K_GATE_OXIDE_TOP_T  */
    K_GATE_OXIDE_SIDE_T = 373,     /* K_GATE_OXIDE_SIDE_T  */
    K_GATE_OXIDE_ER = 374,         /* K_GATE_OXIDE_ER  */
    K_GATE_POLY_TOP_T = 375,       /* K_GATE_POLY_TOP_T  */
    K_GATE_POLY_SIDE_T = 376,      /* K_GATE_POLY_SIDE_T  */
    K_CHANNEL_ER = 377,            /* K_CHANNEL_ER  */
    K_RAISED_DIFFUSION_GROWTH = 378, /* K_RAISED_DIFFUSION_GROWTH  */
    K_GATE_DIFFUSION_LAYER_PAIR = 379, /* K_GATE_DIFFUSION_LAYER_PAIR  */
    K_RPV_VS_WIDTH_AND_LENGTH = 380, /* K_RPV_VS_WIDTH_AND_LENGTH  */
    K_RAISED_DIFFUSION_ETCH = 381, /* K_RAISED_DIFFUSION_ETCH  */
    K_RAISED_DIFFUSION_GATE_SIDE_CONFORMAL_ER = 382, /* K_RAISED_DIFFUSION_GATE_SIDE_CONFORMAL_ER  */
    KEYWORD = 383,                 /* KEYWORD  */
    PROCESS_NAME = 384,            /* PROCESS_NAME  */
    NUMBER = 385                   /* NUMBER  */
  };
  typedef enum itf_tokentype itf_token_kind_t;
#endif

/* Value type.  */
#if ! defined ITF_STYPE && ! defined ITF_STYPE_IS_DECLARED
union ITF_STYPE
{
#line 42 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"

  double  dval;
  char*   string;
  void*   ent;

#line 225 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.hpp"

};
typedef union ITF_STYPE ITF_STYPE;
# define ITF_STYPE_IS_TRIVIAL 1
# define ITF_STYPE_IS_DECLARED 1
#endif

/* Location type.  */
#if ! defined ITF_LTYPE && ! defined ITF_LTYPE_IS_DECLARED
typedef struct ITF_LTYPE ITF_LTYPE;
struct ITF_LTYPE
{
  int first_line;
  int first_column;
  int last_line;
  int last_column;
};
# define ITF_LTYPE_IS_DECLARED 1
# define ITF_LTYPE_IS_TRIVIAL 1
#endif




int itf_parse (void);

/* "%code provides" blocks.  */
#line 32 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"


#undef YY_DECL
#define YY_DECL int itf_lex(ITF_STYPE* yylval_param, ITF_LTYPE* yylloc_param)
YY_DECL;

void itf_error(ITF_LTYPE*, const char*);


#line 263 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.hpp"

#endif /* !YY_ITF_HOME_LXQ_AIEDA_IEDA_AI_BUILD_AES13_SRC_OPERATION_IRCX_SOURCE_PARSER_ITF_GENERATED_ITF_PARSER_HPP_INCLUDED  */
