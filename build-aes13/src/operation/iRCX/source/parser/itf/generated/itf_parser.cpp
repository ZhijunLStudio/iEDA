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
#define YYPURE 2

/* Push parsers.  */
#define YYPUSH 0

/* Pull parsers.  */
#define YYPULL 1

/* Substitute the type names.  */
#define YYSTYPE         ITF_STYPE
#define YYLTYPE         ITF_LTYPE
/* Substitute the variable and function names.  */
#define yyparse         itf_parse
#define yylex           itf_lex
#define yyerror         itf_error
#define yydebug         itf_debug
#define yynerrs         itf_nerrs


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

#include "itf_parser.hpp"
/* Symbol kind.  */
enum yysymbol_kind_t
{
  YYSYMBOL_YYEMPTY = -2,
  YYSYMBOL_YYEOF = 0,                      /* "end of file"  */
  YYSYMBOL_YYerror = 1,                    /* error  */
  YYSYMBOL_YYUNDEF = 2,                    /* "invalid token"  */
  YYSYMBOL_K_TECHNOLOGY = 3,               /* K_TECHNOLOGY  */
  YYSYMBOL_K_PROCESS_FOUNDRY = 4,          /* K_PROCESS_FOUNDRY  */
  YYSYMBOL_K_GLOBAL_TEMPERATURE = 5,       /* K_GLOBAL_TEMPERATURE  */
  YYSYMBOL_K_BACKGROUND_ER = 6,            /* K_BACKGROUND_ER  */
  YYSYMBOL_K_HALF_NODE_SCALE_FACTOR = 7,   /* K_HALF_NODE_SCALE_FACTOR  */
  YYSYMBOL_K_PROCESS_NODE = 8,             /* K_PROCESS_NODE  */
  YYSYMBOL_K_PROCESS_TYPE = 9,             /* K_PROCESS_TYPE  */
  YYSYMBOL_K_PROCESS_VERSION = 10,         /* K_PROCESS_VERSION  */
  YYSYMBOL_K_PROCESS_CORNER = 11,          /* K_PROCESS_CORNER  */
  YYSYMBOL_K_REFERENCE_DIRECTION = 12,     /* K_REFERENCE_DIRECTION  */
  YYSYMBOL_K_USE_SI_DENSITY = 13,          /* K_USE_SI_DENSITY  */
  YYSYMBOL_K_YES = 14,                     /* K_YES  */
  YYSYMBOL_K_NO = 15,                      /* K_NO  */
  YYSYMBOL_K_DROP_FACTOR_LATERAL_SPACING = 16, /* K_DROP_FACTOR_LATERAL_SPACING  */
  YYSYMBOL_K_DIELECTRIC = 17,              /* K_DIELECTRIC  */
  YYSYMBOL_K_DIELECTRIC_LAYER = 18,        /* K_DIELECTRIC_LAYER  */
  YYSYMBOL_K_ER = 19,                      /* K_ER  */
  YYSYMBOL_K_THICKNESS = 20,               /* K_THICKNESS  */
  YYSYMBOL_K_MEASURED_FROM = 21,           /* K_MEASURED_FROM  */
  YYSYMBOL_K_TOP_OF_CHIP = 22,             /* K_TOP_OF_CHIP  */
  YYSYMBOL_K_SW_T = 23,                    /* K_SW_T  */
  YYSYMBOL_K_TW_T = 24,                    /* K_TW_T  */
  YYSYMBOL_K_ASSOCIATED_CONDUCTOR = 25,    /* K_ASSOCIATED_CONDUCTOR  */
  YYSYMBOL_K_IS_CONFORMAL = 26,            /* K_IS_CONFORMAL  */
  YYSYMBOL_K_DAMAGE_THICKNESS = 27,        /* K_DAMAGE_THICKNESS  */
  YYSYMBOL_K_DAMAGE_ER = 28,               /* K_DAMAGE_ER  */
  YYSYMBOL_K_CONDUCTOR = 29,               /* K_CONDUCTOR  */
  YYSYMBOL_K_IS_PLANAR = 30,               /* K_IS_PLANAR  */
  YYSYMBOL_K_WMIN = 31,                    /* K_WMIN  */
  YYSYMBOL_K_SMIN = 32,                    /* K_SMIN  */
  YYSYMBOL_K_AIR_GAP_VS_SPACING = 33,      /* K_AIR_GAP_VS_SPACING  */
  YYSYMBOL_K_SPACINGS = 34,                /* K_SPACINGS  */
  YYSYMBOL_K_AIR_GAP_WIDTHS = 35,          /* K_AIR_GAP_WIDTHS  */
  YYSYMBOL_K_AIR_GAP_THICKNESSES = 36,     /* K_AIR_GAP_THICKNESSES  */
  YYSYMBOL_K_AIR_GAP_BOTTOM_HEIGHTS = 37,  /* K_AIR_GAP_BOTTOM_HEIGHTS  */
  YYSYMBOL_K_BOTTOM_DIELECTRIC_THICKNESS = 38, /* K_BOTTOM_DIELECTRIC_THICKNESS  */
  YYSYMBOL_K_BOTTOM_DIELECTRIC_ER = 39,    /* K_BOTTOM_DIELECTRIC_ER  */
  YYSYMBOL_K_BOTTOM_THICKNESS_VS_SI_WIDTH = 40, /* K_BOTTOM_THICKNESS_VS_SI_WIDTH  */
  YYSYMBOL_K_RESISTIVE_ONLY = 41,          /* K_RESISTIVE_ONLY  */
  YYSYMBOL_K_CAPACITIVE_ONLY = 42,         /* K_CAPACITIVE_ONLY  */
  YYSYMBOL_K_T0 = 43,                      /* K_T0  */
  YYSYMBOL_K_CRT1 = 44,                    /* K_CRT1  */
  YYSYMBOL_K_CRT2 = 45,                    /* K_CRT2  */
  YYSYMBOL_K_DROP_FACTOR = 46,             /* K_DROP_FACTOR  */
  YYSYMBOL_K_ETCH = 47,                    /* K_ETCH  */
  YYSYMBOL_K_CAPACITIVE_ONLY_ETCH = 48,    /* K_CAPACITIVE_ONLY_ETCH  */
  YYSYMBOL_K_RESISTIVE_ONLY_ETCH = 49,     /* K_RESISTIVE_ONLY_ETCH  */
  YYSYMBOL_K_ETCH_VS_WIDTH_AND_SPACING = 50, /* K_ETCH_VS_WIDTH_AND_SPACING  */
  YYSYMBOL_K_WIDTHS = 51,                  /* K_WIDTHS  */
  YYSYMBOL_K_VALUES = 52,                  /* K_VALUES  */
  YYSYMBOL_K_ETCH_FROM_TOP = 53,           /* K_ETCH_FROM_TOP  */
  YYSYMBOL_K_FILL_RATIO = 54,              /* K_FILL_RATIO  */
  YYSYMBOL_K_FILL_SPACING = 55,            /* K_FILL_SPACING  */
  YYSYMBOL_K_FILL_WIDTH = 56,              /* K_FILL_WIDTH  */
  YYSYMBOL_K_FILL_TYPE = 57,               /* K_FILL_TYPE  */
  YYSYMBOL_K_GROUNDED = 58,                /* K_GROUNDED  */
  YYSYMBOL_K_FLOATING = 59,                /* K_FLOATING  */
  YYSYMBOL_K_GATE_TO_CONTACT_SMIN = 60,    /* K_GATE_TO_CONTACT_SMIN  */
  YYSYMBOL_K_GATE_TO_DIFFUSION_CAP = 61,   /* K_GATE_TO_DIFFUSION_CAP  */
  YYSYMBOL_K_NUMBER_OF_TABLES = 62,        /* K_NUMBER_OF_TABLES  */
  YYSYMBOL_K_CONTACT_TO_CONTACT_SPACINGS = 63, /* K_CONTACT_TO_CONTACT_SPACINGS  */
  YYSYMBOL_K_GATE_TO_CONTACT_SPACINGS = 64, /* K_GATE_TO_CONTACT_SPACINGS  */
  YYSYMBOL_K_CAPS_PER_MICRON = 65,         /* K_CAPS_PER_MICRON  */
  YYSYMBOL_K_THICKNESS_CHANGES = 66,       /* K_THICKNESS_CHANGES  */
  YYSYMBOL_K_LAYER_TYPE = 67,              /* K_LAYER_TYPE  */
  YYSYMBOL_K_POLYNOMIAL_BASED_THICKNESS_VARIATION = 68, /* K_POLYNOMIAL_BASED_THICKNESS_VARIATION  */
  YYSYMBOL_K_DENSITY_POLYNOMIAL_ORDERS = 69, /* K_DENSITY_POLYNOMIAL_ORDERS  */
  YYSYMBOL_K_WIDTH_POLYNOMIAL_ORDERS = 70, /* K_WIDTH_POLYNOMIAL_ORDERS  */
  YYSYMBOL_K_WIDTH_RANGES = 71,            /* K_WIDTH_RANGES  */
  YYSYMBOL_K_POLYNOMIAL_COEFFICIENTS = 72, /* K_POLYNOMIAL_COEFFICIENTS  */
  YYSYMBOL_K_RPSQ = 73,                    /* K_RPSQ  */
  YYSYMBOL_K_RHO = 74,                     /* K_RHO  */
  YYSYMBOL_K_RPSQ_VS_SI_WIDTH = 75,        /* K_RPSQ_VS_SI_WIDTH  */
  YYSYMBOL_K_RPSQ_VS_WIDTH_AND_SPACING = 76, /* K_RPSQ_VS_WIDTH_AND_SPACING  */
  YYSYMBOL_K_WIDTH = 77,                   /* K_WIDTH  */
  YYSYMBOL_K_SIDE_TANGENT = 78,            /* K_SIDE_TANGENT  */
  YYSYMBOL_K_THICKNESS_VS_DENSITY = 79,    /* K_THICKNESS_VS_DENSITY  */
  YYSYMBOL_K_THICKNESS_VS_WIDTH_AND_SPACING = 80, /* K_THICKNESS_VS_WIDTH_AND_SPACING  */
  YYSYMBOL_K_TVF_ADJUSTMENT_TABLES = 81,   /* K_TVF_ADJUSTMENT_TABLES  */
  YYSYMBOL_K_BOTTOM_THICKNESS_VS_WIDTH_AND_SPACING = 82, /* K_BOTTOM_THICKNESS_VS_WIDTH_AND_SPACING  */
  YYSYMBOL_K_BOTTOM_THICKNESS_VS_WIDTH_AND_DELTAPD = 83, /* K_BOTTOM_THICKNESS_VS_WIDTH_AND_DELTAPD  */
  YYSYMBOL_K_VIA = 84,                     /* K_VIA  */
  YYSYMBOL_K_FROM = 85,                    /* K_FROM  */
  YYSYMBOL_K_TO = 86,                      /* K_TO  */
  YYSYMBOL_K_CRT_VS_AREA = 87,             /* K_CRT_VS_AREA  */
  YYSYMBOL_K_RPV = 88,                     /* K_RPV  */
  YYSYMBOL_K_AREA = 89,                    /* K_AREA  */
  YYSYMBOL_K_RPV_VS_AREA = 90,             /* K_RPV_VS_AREA  */
  YYSYMBOL_K_ETCH_VS_WIDTH_AND_LENGTH = 91, /* K_ETCH_VS_WIDTH_AND_LENGTH  */
  YYSYMBOL_K_VARIATION_PARAMETERS = 92,    /* K_VARIATION_PARAMETERS  */
  YYSYMBOL_K_DENSITY_BOX_WEIGHTING_FACTOR = 93, /* K_DENSITY_BOX_WEIGHTING_FACTOR  */
  YYSYMBOL_K_ILD_VS_WIDTH_AND_SPACING = 94, /* K_ILD_VS_WIDTH_AND_SPACING  */
  YYSYMBOL_K_DELTAPD = 95,                 /* K_DELTAPD  */
  YYSYMBOL_K_LENGTHS = 96,                 /* K_LENGTHS  */
  YYSYMBOL_K_RHO_VS_SI_WIDTH_AND_THICKNESS = 97, /* K_RHO_VS_SI_WIDTH_AND_THICKNESS  */
  YYSYMBOL_K_RHO_VS_WIDTH_AND_SPACING = 98, /* K_RHO_VS_WIDTH_AND_SPACING  */
  YYSYMBOL_K_ETCH_VS_CONTACT_AND_GATE_SPACINGS = 99, /* K_ETCH_VS_CONTACT_AND_GATE_SPACINGS  */
  YYSYMBOL_K_CRT_VS_SI_WIDTH = 100,        /* K_CRT_VS_SI_WIDTH  */
  YYSYMBOL_K_DENSITY_BOUNDS_VS_WIDTH = 101, /* K_DENSITY_BOUNDS_VS_WIDTH  */
  YYSYMBOL_K_THICKNESS_BOUNDS = 102,       /* K_THICKNESS_BOUNDS  */
  YYSYMBOL_K_DEVICE_TYPE = 103,            /* K_DEVICE_TYPE  */
  YYSYMBOL_K_PARALLEL_TO_REFERENCE = 104,  /* K_PARALLEL_TO_REFERENCE  */
  YYSYMBOL_K_PERPENDICULAR_TO_REFERENCE = 105, /* K_PERPENDICULAR_TO_REFERENCE  */
  YYSYMBOL_K_PARALLEL_TO_GATE = 106,       /* K_PARALLEL_TO_GATE  */
  YYSYMBOL_K_BW_T = 107,                   /* K_BW_T  */
  YYSYMBOL_K_LINKED_TO = 108,              /* K_LINKED_TO  */
  YYSYMBOL_K_EXTENSIONMIN = 109,           /* K_EXTENSIONMIN  */
  YYSYMBOL_K_RAISED_DIFFUSION_THICKNESS = 110, /* K_RAISED_DIFFUSION_THICKNESS  */
  YYSYMBOL_K_RAISED_DIFFUSION_TO_GATE_SMIN = 111, /* K_RAISED_DIFFUSION_TO_GATE_SMIN  */
  YYSYMBOL_K_MULTIGATE = 112,              /* K_MULTIGATE  */
  YYSYMBOL_K_FIN_SPACING = 113,            /* K_FIN_SPACING  */
  YYSYMBOL_K_FIN_WIDTH = 114,              /* K_FIN_WIDTH  */
  YYSYMBOL_K_FIN_LENGTH = 115,             /* K_FIN_LENGTH  */
  YYSYMBOL_K_FIN_THICKNESS = 116,          /* K_FIN_THICKNESS  */
  YYSYMBOL_K_GATE_OXIDE_TOP_T = 117,       /* K_GATE_OXIDE_TOP_T  */
  YYSYMBOL_K_GATE_OXIDE_SIDE_T = 118,      /* K_GATE_OXIDE_SIDE_T  */
  YYSYMBOL_K_GATE_OXIDE_ER = 119,          /* K_GATE_OXIDE_ER  */
  YYSYMBOL_K_GATE_POLY_TOP_T = 120,        /* K_GATE_POLY_TOP_T  */
  YYSYMBOL_K_GATE_POLY_SIDE_T = 121,       /* K_GATE_POLY_SIDE_T  */
  YYSYMBOL_K_CHANNEL_ER = 122,             /* K_CHANNEL_ER  */
  YYSYMBOL_K_RAISED_DIFFUSION_GROWTH = 123, /* K_RAISED_DIFFUSION_GROWTH  */
  YYSYMBOL_K_GATE_DIFFUSION_LAYER_PAIR = 124, /* K_GATE_DIFFUSION_LAYER_PAIR  */
  YYSYMBOL_K_RPV_VS_WIDTH_AND_LENGTH = 125, /* K_RPV_VS_WIDTH_AND_LENGTH  */
  YYSYMBOL_K_RAISED_DIFFUSION_ETCH = 126,  /* K_RAISED_DIFFUSION_ETCH  */
  YYSYMBOL_K_RAISED_DIFFUSION_GATE_SIDE_CONFORMAL_ER = 127, /* K_RAISED_DIFFUSION_GATE_SIDE_CONFORMAL_ER  */
  YYSYMBOL_KEYWORD = 128,                  /* KEYWORD  */
  YYSYMBOL_PROCESS_NAME = 129,             /* PROCESS_NAME  */
  YYSYMBOL_NUMBER = 130,                   /* NUMBER  */
  YYSYMBOL_131_ = 131,                     /* '='  */
  YYSYMBOL_132_ = 132,                     /* '{'  */
  YYSYMBOL_133_ = 133,                     /* '}'  */
  YYSYMBOL_134_ = 134,                     /* '('  */
  YYSYMBOL_135_ = 135,                     /* ','  */
  YYSYMBOL_136_ = 136,                     /* ')'  */
  YYSYMBOL_YYACCEPT = 137,                 /* $accept  */
  YYSYMBOL_itf_file = 138,                 /* itf_file  */
  YYSYMBOL_file_optionals = 139,           /* file_optionals  */
  YYSYMBOL_file_optional = 140,            /* file_optional  */
  YYSYMBOL_tech = 141,                     /* tech  */
  YYSYMBOL_global_temperature = 142,       /* global_temperature  */
  YYSYMBOL_background_er = 143,            /* background_er  */
  YYSYMBOL_half_node_scale_factor = 144,   /* half_node_scale_factor  */
  YYSYMBOL_use_si_density = 145,           /* use_si_density  */
  YYSYMBOL_use_si_density_value = 146,     /* use_si_density_value  */
  YYSYMBOL_drop_factor_lateral_spacing = 147, /* drop_factor_lateral_spacing  */
  YYSYMBOL_process_foundry = 148,          /* process_foundry  */
  YYSYMBOL_process_node = 149,             /* process_node  */
  YYSYMBOL_process_type = 150,             /* process_type  */
  YYSYMBOL_process_version = 151,          /* process_version  */
  YYSYMBOL_process_corner = 152,           /* process_corner  */
  YYSYMBOL_reference_direction = 153,      /* reference_direction  */
  YYSYMBOL_layers = 154,                   /* layers  */
  YYSYMBOL_x_eol = 155,                    /* x_eol  */
  YYSYMBOL_dielectric = 156,               /* dielectric  */
  YYSYMBOL_157_1 = 157,                    /* $@1  */
  YYSYMBOL_158_2 = 158,                    /* $@2  */
  YYSYMBOL_layer_name = 159,               /* layer_name  */
  YYSYMBOL_dielectric_properties = 160,    /* dielectric_properties  */
  YYSYMBOL_dielectric_property = 161,      /* dielectric_property  */
  YYSYMBOL_er = 162,                       /* er  */
  YYSYMBOL_thickness = 163,                /* thickness  */
  YYSYMBOL_diel_measured_from = 164,       /* diel_measured_from  */
  YYSYMBOL_measured_from = 165,            /* measured_from  */
  YYSYMBOL_measured_from_value = 166,      /* measured_from_value  */
  YYSYMBOL_sw_t = 167,                     /* sw_t  */
  YYSYMBOL_tw_t = 168,                     /* tw_t  */
  YYSYMBOL_associated_conductor = 169,     /* associated_conductor  */
  YYSYMBOL_damage = 170,                   /* damage  */
  YYSYMBOL_bw_t = 171,                     /* bw_t  */
  YYSYMBOL_conductor = 172,                /* conductor  */
  YYSYMBOL_173_3 = 173,                    /* $@3  */
  YYSYMBOL_conductor_properties = 174,     /* conductor_properties  */
  YYSYMBOL_conductor_property = 175,       /* conductor_property  */
  YYSYMBOL_wmin = 176,                     /* wmin  */
  YYSYMBOL_smin = 177,                     /* smin  */
  YYSYMBOL_air_gap_vs_spacing = 178,       /* air_gap_vs_spacing  */
  YYSYMBOL_spacings = 179,                 /* spacings  */
  YYSYMBOL_float_list = 180,               /* float_list  */
  YYSYMBOL_air_gap_widths = 181,           /* air_gap_widths  */
  YYSYMBOL_air_gap_thicknesses = 182,      /* air_gap_thicknesses  */
  YYSYMBOL_air_gap_bottom_heights = 183,   /* air_gap_bottom_heights  */
  YYSYMBOL_bottom_dielectric_property = 184, /* bottom_dielectric_property  */
  YYSYMBOL_bottom_thickness_vs_si_width = 185, /* bottom_thickness_vs_si_width  */
  YYSYMBOL_bottom_thickness_vs_si_width_type = 186, /* bottom_thickness_vs_si_width_type  */
  YYSYMBOL_float_pair_list = 187,          /* float_pair_list  */
  YYSYMBOL_t0 = 188,                       /* t0  */
  YYSYMBOL_crt_stmt = 189,                 /* crt_stmt  */
  YYSYMBOL_crt1 = 190,                     /* crt1  */
  YYSYMBOL_crt2 = 191,                     /* crt2  */
  YYSYMBOL_crt_vs_si_width = 192,          /* crt_vs_si_width  */
  YYSYMBOL_siw_crt1_crt2_list = 193,       /* siw_crt1_crt2_list  */
  YYSYMBOL_density_box_weight_factor = 194, /* density_box_weight_factor  */
  YYSYMBOL_s_w_list = 195,                 /* s_w_list  */
  YYSYMBOL_drop_factor = 196,              /* drop_factor  */
  YYSYMBOL_etch_stmt = 197,                /* etch_stmt  */
  YYSYMBOL_etch_vs_width_and_spacing = 198, /* etch_vs_width_and_spacing  */
  YYSYMBOL_199_4 = 199,                    /* $@4  */
  YYSYMBOL_etch_effect_type = 200,         /* etch_effect_type  */
  YYSYMBOL_apply_etch_to = 201,            /* apply_etch_to  */
  YYSYMBOL_widths = 202,                   /* widths  */
  YYSYMBOL_values = 203,                   /* values  */
  YYSYMBOL_fill_stmt = 204,                /* fill_stmt  */
  YYSYMBOL_fill_type = 205,                /* fill_type  */
  YYSYMBOL_gate_to_contact_smin = 206,     /* gate_to_contact_smin  */
  YYSYMBOL_gate_to_diffusion_cap = 207,    /* gate_to_diffusion_cap  */
  YYSYMBOL_number_of_tables = 208,         /* number_of_tables  */
  YYSYMBOL_model_list = 209,               /* model_list  */
  YYSYMBOL_model = 210,                    /* model  */
  YYSYMBOL_211_5 = 211,                    /* $@5  */
  YYSYMBOL_model_name = 212,               /* model_name  */
  YYSYMBOL_contact_to_contact_spacings = 213, /* contact_to_contact_spacings  */
  YYSYMBOL_gate_to_contact_spacings = 214, /* gate_to_contact_spacings  */
  YYSYMBOL_caps_per_micron = 215,          /* caps_per_micron  */
  YYSYMBOL_ild_vs_width_and_spacing = 216, /* ild_vs_width_and_spacing  */
  YYSYMBOL_217_6 = 217,                    /* $@6  */
  YYSYMBOL_ild_diel_layer_token = 218,     /* ild_diel_layer_token  */
  YYSYMBOL_thickness_changes = 219,        /* thickness_changes  */
  YYSYMBOL_layer_type = 220,               /* layer_type  */
  YYSYMBOL_layer_type_value = 221,         /* layer_type_value  */
  YYSYMBOL_polynomial_based_thickness_variation = 222, /* polynomial_based_thickness_variation  */
  YYSYMBOL_polynomial_based_thickness_variation_options = 223, /* polynomial_based_thickness_variation_options  */
  YYSYMBOL_polynomial_based_thickness_variation_option = 224, /* polynomial_based_thickness_variation_option  */
  YYSYMBOL_density_polynomial_orders = 225, /* density_polynomial_orders  */
  YYSYMBOL_equal_op = 226,                 /* equal_op  */
  YYSYMBOL_width_polynomial_orders = 227,  /* width_polynomial_orders  */
  YYSYMBOL_width_ranges = 228,             /* width_ranges  */
  YYSYMBOL_int_comma_list = 229,           /* int_comma_list  */
  YYSYMBOL_float_comma_list = 230,         /* float_comma_list  */
  YYSYMBOL_polynomial_valueicients_lists = 231, /* polynomial_valueicients_lists  */
  YYSYMBOL_density_bounds_vs_width = 232,  /* density_bounds_vs_width  */
  YYSYMBOL_tuple_3_list = 233,             /* tuple_3_list  */
  YYSYMBOL_thickness_bounds = 234,         /* thickness_bounds  */
  YYSYMBOL_rpsq_stmt = 235,                /* rpsq_stmt  */
  YYSYMBOL_rho = 236,                      /* rho  */
  YYSYMBOL_rpsq_vs_si_width = 237,         /* rpsq_vs_si_width  */
  YYSYMBOL_rpsq_vs_width_and_spacing = 238, /* rpsq_vs_width_and_spacing  */
  YYSYMBOL_239_7 = 239,                    /* $@7  */
  YYSYMBOL_rho_vs_si_width_and_thickness = 240, /* rho_vs_si_width_and_thickness  */
  YYSYMBOL_241_8 = 241,                    /* $@8  */
  YYSYMBOL_width_list = 242,               /* width_list  */
  YYSYMBOL_thickness_list = 243,           /* thickness_list  */
  YYSYMBOL_rho_vs_width_and_spacing = 244, /* rho_vs_width_and_spacing  */
  YYSYMBOL_245_9 = 245,                    /* $@9  */
  YYSYMBOL_side_tangent = 246,             /* side_tangent  */
  YYSYMBOL_thickness_vs_density = 247,     /* thickness_vs_density  */
  YYSYMBOL_thickness_vs_density_type = 248, /* thickness_vs_density_type  */
  YYSYMBOL_thickness_vs_width_and_spacing = 249, /* thickness_vs_width_and_spacing  */
  YYSYMBOL_250_10 = 250,                   /* $@10  */
  YYSYMBOL_thickness_vs_width_and_spacing_type = 251, /* thickness_vs_width_and_spacing_type  */
  YYSYMBOL_tvf_adjustment_tables = 252,    /* tvf_adjustment_tables  */
  YYSYMBOL_bottom_thickness_vs_width_and_others = 253, /* bottom_thickness_vs_width_and_others  */
  YYSYMBOL_bottom_thickness_vs_width_and_other = 254, /* bottom_thickness_vs_width_and_other  */
  YYSYMBOL_bottom_thickness_vs_width_and_spacing = 255, /* bottom_thickness_vs_width_and_spacing  */
  YYSYMBOL_256_11 = 256,                   /* $@11  */
  YYSYMBOL_bottom_thickness_vs_width_and_deltapd = 257, /* bottom_thickness_vs_width_and_deltapd  */
  YYSYMBOL_258_12 = 258,                   /* $@12  */
  YYSYMBOL_deltapd = 259,                  /* deltapd  */
  YYSYMBOL_device_type = 260,              /* device_type  */
  YYSYMBOL_keyword_list = 261,             /* keyword_list  */
  YYSYMBOL_linked_to = 262,                /* linked_to  */
  YYSYMBOL_extensionmin = 263,             /* extensionmin  */
  YYSYMBOL_raised_diffusion_thickness = 264, /* raised_diffusion_thickness  */
  YYSYMBOL_raised_diffusion_to_gate_smin = 265, /* raised_diffusion_to_gate_smin  */
  YYSYMBOL_raised_diffusion_etch = 266,    /* raised_diffusion_etch  */
  YYSYMBOL_raised_diffusion_gate_side_conformal_er = 267, /* raised_diffusion_gate_side_conformal_er  */
  YYSYMBOL_multigate = 268,                /* multigate  */
  YYSYMBOL_multigate_properties = 269,     /* multigate_properties  */
  YYSYMBOL_multigate_property = 270,       /* multigate_property  */
  YYSYMBOL_fin_spacing = 271,              /* fin_spacing  */
  YYSYMBOL_fin_width = 272,                /* fin_width  */
  YYSYMBOL_fin_length = 273,               /* fin_length  */
  YYSYMBOL_fin_thickness = 274,            /* fin_thickness  */
  YYSYMBOL_gate_oxide_top_t = 275,         /* gate_oxide_top_t  */
  YYSYMBOL_gate_oxide_side_t = 276,        /* gate_oxide_side_t  */
  YYSYMBOL_gate_oxide_er = 277,            /* gate_oxide_er  */
  YYSYMBOL_gate_poly_top_t = 278,          /* gate_poly_top_t  */
  YYSYMBOL_gate_poly_side_t = 279,         /* gate_poly_side_t  */
  YYSYMBOL_channel_er = 280,               /* channel_er  */
  YYSYMBOL_raised_diffusion_growth = 281,  /* raised_diffusion_growth  */
  YYSYMBOL_gate_diffusion_layer_pair = 282, /* gate_diffusion_layer_pair  */
  YYSYMBOL_gate_diffusion_layer_pair_list = 283, /* gate_diffusion_layer_pair_list  */
  YYSYMBOL_vias = 284,                     /* vias  */
  YYSYMBOL_via = 285,                      /* via  */
  YYSYMBOL_286_13 = 286,                   /* $@13  */
  YYSYMBOL_via_properties = 287,           /* via_properties  */
  YYSYMBOL_via_property = 288,             /* via_property  */
  YYSYMBOL_from = 289,                     /* from  */
  YYSYMBOL_to = 290,                       /* to  */
  YYSYMBOL_crt_property = 291,             /* crt_property  */
  YYSYMBOL_crt_vs_area = 292,              /* crt_vs_area  */
  YYSYMBOL_area_crt1_crt2_list = 293,      /* area_crt1_crt2_list  */
  YYSYMBOL_rho_property = 294,             /* rho_property  */
  YYSYMBOL_rpv = 295,                      /* rpv  */
  YYSYMBOL_area = 296,                     /* area  */
  YYSYMBOL_rpv_vs_area = 297,              /* rpv_vs_area  */
  YYSYMBOL_area_rpv_list = 298,            /* area_rpv_list  */
  YYSYMBOL_etch_property = 299,            /* etch_property  */
  YYSYMBOL_etch_vs_contact_and_gate_spacings = 300, /* etch_vs_contact_and_gate_spacings  */
  YYSYMBOL_301_14 = 301,                   /* $@14  */
  YYSYMBOL_etch_vs_contact_and_gate_spacings_property = 302, /* etch_vs_contact_and_gate_spacings_property  */
  YYSYMBOL_table = 303,                    /* table  */
  YYSYMBOL_name_tables = 304,              /* name_tables  */
  YYSYMBOL_table_name = 305,               /* table_name  */
  YYSYMBOL_etch_vs_width_and_length = 306, /* etch_vs_width_and_length  */
  YYSYMBOL_307_15 = 307,                   /* $@15  */
  YYSYMBOL_308_16 = 308,                   /* $@16  */
  YYSYMBOL_309_17 = 309,                   /* $@17  */
  YYSYMBOL_310_18 = 310,                   /* $@18  */
  YYSYMBOL_etch_width_length_effect_type = 311, /* etch_width_length_effect_type  */
  YYSYMBOL_rpv_vs_width_and_length = 312,  /* rpv_vs_width_and_length  */
  YYSYMBOL_variation_params = 313,         /* variation_params  */
  YYSYMBOL_variation_params_list = 314,    /* variation_params_list  */
  YYSYMBOL_variation_param = 315,          /* variation_param  */
  YYSYMBOL_variation_param_name = 316,     /* variation_param_name  */
  YYSYMBOL_variation_param_table = 317,    /* variation_param_table  */
  YYSYMBOL_variation_param_table_term = 318, /* variation_param_table_term  */
  YYSYMBOL_variation_param_type = 319      /* variation_param_type  */
};
typedef enum yysymbol_kind_t yysymbol_kind_t;


/* Second part of user prologue.  */
#line 52 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"


namespace itf {

#define CALLBACK(func, typ, data) \
  if (func) { \
    (*func) (typ, data, itfSettings->user_data); \
  }

extern itfrData* itfData;
// var
char* v_layer_name = nullptr;
char* v_measured_from = nullptr;
char* v_model_name = nullptr;
char* v_table_name = nullptr;
char* v_etch_effect_type = nullptr;
float v_thickness;
float v_sw_t;
float v_tw_t;
float v_t0;
float v_crt1;
float v_crt2;
float v_rho;
int v_number_of_tables;
std::vector<int> v_int_list;
std::vector<float> v_float_list;
std::vector<std::pair<float, float>> v_float_pair_list;
itf2DLUT<float, float, float> v_lut;
itf2DLUT<float, float, std::pair<float, float>> v_etch_wlv_lut;
itfiVPT v_vpt;
unsigned v_is_lut_working = 0;
unsigned v_flag_dielectric = 0;

#line 463 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"


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
typedef yytype_int16 yy_state_t;

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
         || (defined ITF_LTYPE_IS_TRIVIAL && ITF_LTYPE_IS_TRIVIAL \
             && defined ITF_STYPE_IS_TRIVIAL && ITF_STYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yy_state_t yyss_alloc;
  YYSTYPE yyvs_alloc;
  YYLTYPE yyls_alloc;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (YYSIZEOF (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (YYSIZEOF (yy_state_t) + YYSIZEOF (YYSTYPE) \
             + YYSIZEOF (YYLTYPE)) \
      + 2 * YYSTACK_GAP_MAXIMUM)

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
#define YYLAST   630

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  137
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  183
/* YYNRULES -- Number of rules.  */
#define YYNRULES  332
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  699

/* YYMAXUTOK -- Last valid token kind.  */
#define YYMAXUTOK   385


/* YYTRANSLATE(TOKEN-NUM) -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex, with out-of-bounds checking.  */
#define YYTRANSLATE(YYX)                                \
  (0 <= (YYX) && (YYX) <= YYMAXUTOK                     \
   ? YY_CAST (yysymbol_kind_t, yytranslate[YYX])        \
   : YYSYMBOL_YYUNDEF)

/* YYTRANSLATE[TOKEN-NUM] -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex.  */
static const yytype_uint8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     134,   136,     2,     2,   135,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,   131,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,   132,     2,   133,     2,     2,     2,     2,
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
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    41,    42,    43,    44,
      45,    46,    47,    48,    49,    50,    51,    52,    53,    54,
      55,    56,    57,    58,    59,    60,    61,    62,    63,    64,
      65,    66,    67,    68,    69,    70,    71,    72,    73,    74,
      75,    76,    77,    78,    79,    80,    81,    82,    83,    84,
      85,    86,    87,    88,    89,    90,    91,    92,    93,    94,
      95,    96,    97,    98,    99,   100,   101,   102,   103,   104,
     105,   106,   107,   108,   109,   110,   111,   112,   113,   114,
     115,   116,   117,   118,   119,   120,   121,   122,   123,   124,
     125,   126,   127,   128,   129,   130
};

#if ITF_DEBUG
/* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_int16 yyrline[] =
{
       0,   125,   125,   131,   132,   136,   140,   144,   148,   152,
     156,   160,   164,   168,   172,   176,   180,   187,   191,   198,
     206,   214,   222,   229,   230,   234,   242,   246,   250,   254,
     258,   262,   266,   271,   276,   281,   282,   287,   291,   286,
     303,   307,   308,   312,   313,   314,   315,   319,   320,   324,
     328,   333,   338,   339,   340,   344,   348,   349,   353,   357,
     361,   365,   374,   382,   381,   391,   392,   396,   397,   398,
     399,   400,   401,   402,   403,   404,   405,   406,   407,   414,
     415,   416,   417,   418,   419,   420,   421,   422,   423,   424,
     425,   426,   427,   428,   429,   430,   431,   432,   433,   434,
     438,   445,   452,   461,   473,   477,   481,   489,   497,   505,
     514,   523,   527,   534,   536,   538,   542,   549,   550,   551,
     555,   562,   569,   576,   580,   584,   588,   594,   598,   602,
     606,   613,   615,   617,   623,   622,   637,   638,   639,   640,
     644,   645,   646,   647,   651,   659,   667,   669,   671,   673,
     677,   679,   684,   691,   701,   708,   709,   714,   713,   731,
     735,   743,   751,   760,   759,   779,   780,   784,   792,   796,
     800,   810,   812,   816,   817,   821,   829,   830,   834,   842,
     850,   851,   852,   856,   857,   858,   862,   870,   874,   880,
     885,   889,   896,   897,   898,   899,   900,   901,   905,   909,
     920,   919,   938,   937,   955,   963,   972,   971,   989,   994,
    1003,  1005,  1007,  1012,  1011,  1030,  1032,  1034,  1038,  1044,
    1045,  1049,  1050,  1055,  1054,  1073,  1072,  1090,  1098,  1104,
    1109,  1113,  1120,  1124,  1131,  1138,  1142,  1146,  1153,  1155,
    1159,  1160,  1161,  1162,  1163,  1164,  1165,  1166,  1167,  1168,
    1169,  1170,  1174,  1178,  1182,  1186,  1190,  1194,  1198,  1202,
    1206,  1210,  1214,  1218,  1224,  1226,  1230,  1235,  1240,  1239,
    1249,  1250,  1254,  1255,  1256,  1257,  1258,  1259,  1260,  1264,
    1271,  1278,  1282,  1283,  1284,  1288,  1294,  1298,  1302,  1303,
    1304,  1305,  1309,  1316,  1323,  1329,  1331,  1335,  1336,  1343,
    1344,  1350,  1349,  1363,  1368,  1376,  1382,  1392,  1396,  1401,
    1406,  1411,  1416,  1400,  1429,  1430,  1432,  1436,  1444,  1447,
    1451,  1452,  1456,  1466,  1473,  1475,  1479,  1489,  1490,  1491,
    1492,  1493,  1494
};
#endif

/** Accessing symbol of state STATE.  */
#define YY_ACCESSING_SYMBOL(State) YY_CAST (yysymbol_kind_t, yystos[State])

#if ITF_DEBUG || 0
/* The user-facing name of the symbol whose (internal) number is
   YYSYMBOL.  No bounds checking.  */
static const char *yysymbol_name (yysymbol_kind_t yysymbol) YY_ATTRIBUTE_UNUSED;

/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "\"end of file\"", "error", "\"invalid token\"", "K_TECHNOLOGY",
  "K_PROCESS_FOUNDRY", "K_GLOBAL_TEMPERATURE", "K_BACKGROUND_ER",
  "K_HALF_NODE_SCALE_FACTOR", "K_PROCESS_NODE", "K_PROCESS_TYPE",
  "K_PROCESS_VERSION", "K_PROCESS_CORNER", "K_REFERENCE_DIRECTION",
  "K_USE_SI_DENSITY", "K_YES", "K_NO", "K_DROP_FACTOR_LATERAL_SPACING",
  "K_DIELECTRIC", "K_DIELECTRIC_LAYER", "K_ER", "K_THICKNESS",
  "K_MEASURED_FROM", "K_TOP_OF_CHIP", "K_SW_T", "K_TW_T",
  "K_ASSOCIATED_CONDUCTOR", "K_IS_CONFORMAL", "K_DAMAGE_THICKNESS",
  "K_DAMAGE_ER", "K_CONDUCTOR", "K_IS_PLANAR", "K_WMIN", "K_SMIN",
  "K_AIR_GAP_VS_SPACING", "K_SPACINGS", "K_AIR_GAP_WIDTHS",
  "K_AIR_GAP_THICKNESSES", "K_AIR_GAP_BOTTOM_HEIGHTS",
  "K_BOTTOM_DIELECTRIC_THICKNESS", "K_BOTTOM_DIELECTRIC_ER",
  "K_BOTTOM_THICKNESS_VS_SI_WIDTH", "K_RESISTIVE_ONLY",
  "K_CAPACITIVE_ONLY", "K_T0", "K_CRT1", "K_CRT2", "K_DROP_FACTOR",
  "K_ETCH", "K_CAPACITIVE_ONLY_ETCH", "K_RESISTIVE_ONLY_ETCH",
  "K_ETCH_VS_WIDTH_AND_SPACING", "K_WIDTHS", "K_VALUES", "K_ETCH_FROM_TOP",
  "K_FILL_RATIO", "K_FILL_SPACING", "K_FILL_WIDTH", "K_FILL_TYPE",
  "K_GROUNDED", "K_FLOATING", "K_GATE_TO_CONTACT_SMIN",
  "K_GATE_TO_DIFFUSION_CAP", "K_NUMBER_OF_TABLES",
  "K_CONTACT_TO_CONTACT_SPACINGS", "K_GATE_TO_CONTACT_SPACINGS",
  "K_CAPS_PER_MICRON", "K_THICKNESS_CHANGES", "K_LAYER_TYPE",
  "K_POLYNOMIAL_BASED_THICKNESS_VARIATION", "K_DENSITY_POLYNOMIAL_ORDERS",
  "K_WIDTH_POLYNOMIAL_ORDERS", "K_WIDTH_RANGES",
  "K_POLYNOMIAL_COEFFICIENTS", "K_RPSQ", "K_RHO", "K_RPSQ_VS_SI_WIDTH",
  "K_RPSQ_VS_WIDTH_AND_SPACING", "K_WIDTH", "K_SIDE_TANGENT",
  "K_THICKNESS_VS_DENSITY", "K_THICKNESS_VS_WIDTH_AND_SPACING",
  "K_TVF_ADJUSTMENT_TABLES", "K_BOTTOM_THICKNESS_VS_WIDTH_AND_SPACING",
  "K_BOTTOM_THICKNESS_VS_WIDTH_AND_DELTAPD", "K_VIA", "K_FROM", "K_TO",
  "K_CRT_VS_AREA", "K_RPV", "K_AREA", "K_RPV_VS_AREA",
  "K_ETCH_VS_WIDTH_AND_LENGTH", "K_VARIATION_PARAMETERS",
  "K_DENSITY_BOX_WEIGHTING_FACTOR", "K_ILD_VS_WIDTH_AND_SPACING",
  "K_DELTAPD", "K_LENGTHS", "K_RHO_VS_SI_WIDTH_AND_THICKNESS",
  "K_RHO_VS_WIDTH_AND_SPACING", "K_ETCH_VS_CONTACT_AND_GATE_SPACINGS",
  "K_CRT_VS_SI_WIDTH", "K_DENSITY_BOUNDS_VS_WIDTH", "K_THICKNESS_BOUNDS",
  "K_DEVICE_TYPE", "K_PARALLEL_TO_REFERENCE",
  "K_PERPENDICULAR_TO_REFERENCE", "K_PARALLEL_TO_GATE", "K_BW_T",
  "K_LINKED_TO", "K_EXTENSIONMIN", "K_RAISED_DIFFUSION_THICKNESS",
  "K_RAISED_DIFFUSION_TO_GATE_SMIN", "K_MULTIGATE", "K_FIN_SPACING",
  "K_FIN_WIDTH", "K_FIN_LENGTH", "K_FIN_THICKNESS", "K_GATE_OXIDE_TOP_T",
  "K_GATE_OXIDE_SIDE_T", "K_GATE_OXIDE_ER", "K_GATE_POLY_TOP_T",
  "K_GATE_POLY_SIDE_T", "K_CHANNEL_ER", "K_RAISED_DIFFUSION_GROWTH",
  "K_GATE_DIFFUSION_LAYER_PAIR", "K_RPV_VS_WIDTH_AND_LENGTH",
  "K_RAISED_DIFFUSION_ETCH", "K_RAISED_DIFFUSION_GATE_SIDE_CONFORMAL_ER",
  "KEYWORD", "PROCESS_NAME", "NUMBER", "'='", "'{'", "'}'", "'('", "','",
  "')'", "$accept", "itf_file", "file_optionals", "file_optional", "tech",
  "global_temperature", "background_er", "half_node_scale_factor",
  "use_si_density", "use_si_density_value", "drop_factor_lateral_spacing",
  "process_foundry", "process_node", "process_type", "process_version",
  "process_corner", "reference_direction", "layers", "x_eol", "dielectric",
  "$@1", "$@2", "layer_name", "dielectric_properties",
  "dielectric_property", "er", "thickness", "diel_measured_from",
  "measured_from", "measured_from_value", "sw_t", "tw_t",
  "associated_conductor", "damage", "bw_t", "conductor", "$@3",
  "conductor_properties", "conductor_property", "wmin", "smin",
  "air_gap_vs_spacing", "spacings", "float_list", "air_gap_widths",
  "air_gap_thicknesses", "air_gap_bottom_heights",
  "bottom_dielectric_property", "bottom_thickness_vs_si_width",
  "bottom_thickness_vs_si_width_type", "float_pair_list", "t0", "crt_stmt",
  "crt1", "crt2", "crt_vs_si_width", "siw_crt1_crt2_list",
  "density_box_weight_factor", "s_w_list", "drop_factor", "etch_stmt",
  "etch_vs_width_and_spacing", "$@4", "etch_effect_type", "apply_etch_to",
  "widths", "values", "fill_stmt", "fill_type", "gate_to_contact_smin",
  "gate_to_diffusion_cap", "number_of_tables", "model_list", "model",
  "$@5", "model_name", "contact_to_contact_spacings",
  "gate_to_contact_spacings", "caps_per_micron",
  "ild_vs_width_and_spacing", "$@6", "ild_diel_layer_token",
  "thickness_changes", "layer_type", "layer_type_value",
  "polynomial_based_thickness_variation",
  "polynomial_based_thickness_variation_options",
  "polynomial_based_thickness_variation_option",
  "density_polynomial_orders", "equal_op", "width_polynomial_orders",
  "width_ranges", "int_comma_list", "float_comma_list",
  "polynomial_valueicients_lists", "density_bounds_vs_width",
  "tuple_3_list", "thickness_bounds", "rpsq_stmt", "rho",
  "rpsq_vs_si_width", "rpsq_vs_width_and_spacing", "$@7",
  "rho_vs_si_width_and_thickness", "$@8", "width_list", "thickness_list",
  "rho_vs_width_and_spacing", "$@9", "side_tangent",
  "thickness_vs_density", "thickness_vs_density_type",
  "thickness_vs_width_and_spacing", "$@10",
  "thickness_vs_width_and_spacing_type", "tvf_adjustment_tables",
  "bottom_thickness_vs_width_and_others",
  "bottom_thickness_vs_width_and_other",
  "bottom_thickness_vs_width_and_spacing", "$@11",
  "bottom_thickness_vs_width_and_deltapd", "$@12", "deltapd",
  "device_type", "keyword_list", "linked_to", "extensionmin",
  "raised_diffusion_thickness", "raised_diffusion_to_gate_smin",
  "raised_diffusion_etch", "raised_diffusion_gate_side_conformal_er",
  "multigate", "multigate_properties", "multigate_property", "fin_spacing",
  "fin_width", "fin_length", "fin_thickness", "gate_oxide_top_t",
  "gate_oxide_side_t", "gate_oxide_er", "gate_poly_top_t",
  "gate_poly_side_t", "channel_er", "raised_diffusion_growth",
  "gate_diffusion_layer_pair", "gate_diffusion_layer_pair_list", "vias",
  "via", "$@13", "via_properties", "via_property", "from", "to",
  "crt_property", "crt_vs_area", "area_crt1_crt2_list", "rho_property",
  "rpv", "area", "rpv_vs_area", "area_rpv_list", "etch_property",
  "etch_vs_contact_and_gate_spacings", "$@14",
  "etch_vs_contact_and_gate_spacings_property", "table", "name_tables",
  "table_name", "etch_vs_width_and_length", "$@15", "$@16", "$@17", "$@18",
  "etch_width_length_effect_type", "rpv_vs_width_and_length",
  "variation_params", "variation_params_list", "variation_param",
  "variation_param_name", "variation_param_table",
  "variation_param_table_term", "variation_param_type", YY_NULLPTR
};

static const char *
yysymbol_name (yysymbol_kind_t yysymbol)
{
  return yytname[yysymbol];
}
#endif

#define YYPACT_NINF (-485)

#define yypact_value_is_default(Yyn) \
  ((Yyn) == YYPACT_NINF)

#define YYTABLE_NINF (-1)

#define yytable_value_is_error(Yyn) \
  0

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
static const yytype_int16 yypact[] =
{
    -485,    36,   268,  -485,   -83,   -56,   -40,    -2,     6,    15,
      34,    38,    86,    93,    97,   109,  -485,  -485,  -485,  -485,
    -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,   -25,
      -5,   -29,   -57,   -76,   -43,   -18,    13,    56,    61,   113,
     125,    91,   112,   122,  -485,  -485,   127,   130,  -485,  -485,
    -485,   175,  -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,
    -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,   127,  -485,
    -485,   129,   127,  -485,   -96,  -485,   134,  -485,  -485,  -485,
    -485,  -485,   154,   156,  -485,    59,   158,   159,  -485,   189,
     162,   164,   165,   170,   171,   172,   173,   174,   176,   177,
     178,   179,  -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,
    -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,   -10,   181,
     183,   186,  -485,   187,   188,   191,   190,    76,   193,   194,
     195,   198,   199,   200,   201,  -485,   202,   203,   204,   205,
     206,   207,   209,   210,   212,   213,   214,  -485,   216,   107,
    -485,   217,   219,  -485,  -485,  -485,   220,   221,   223,   224,
     225,   226,   227,   228,  -485,  -485,  -485,  -485,  -485,  -485,
    -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,
    -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,
    -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,
    -485,  -485,  -485,  -485,  -485,  -485,   180,   208,   211,   215,
     218,   230,   231,   232,   233,   234,   235,  -485,    65,    28,
     236,   237,   238,  -485,   239,   240,  -485,  -485,  -485,  -485,
    -485,  -485,  -485,  -485,  -485,  -485,  -485,   242,    -1,   127,
     243,   244,   260,   245,  -485,  -485,   246,   247,   249,   250,
     251,   252,   253,   254,   -12,   255,   256,   257,   108,   258,
     304,   185,   307,   259,   261,  -485,   262,   263,  -485,  -485,
     264,   145,  -485,  -485,   265,   266,   267,  -485,  -485,   127,
     270,   271,   272,   273,   274,  -485,  -485,  -485,  -485,  -485,
    -485,  -485,  -485,  -485,  -485,  -485,    55,   275,   276,   277,
     278,   280,   281,   282,  -485,  -485,   283,  -485,  -485,  -485,
    -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,
    -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,   127,  -485,
     279,   286,   287,   288,   290,  -485,  -485,  -485,  -485,  -485,
    -485,  -485,   289,   285,   351,  -485,  -485,  -485,  -485,  -485,
    -485,  -485,  -485,  -485,  -485,  -485,    53,  -485,  -485,  -485,
    -485,  -485,  -485,  -485,   291,  -485,  -485,  -485,   292,   322,
    -485,  -485,    60,   260,  -485,  -485,  -485,  -485,   293,   -60,
      63,   182,   229,   260,    68,   -94,  -485,  -485,  -485,  -485,
    -485,  -485,  -485,  -485,   294,   127,   127,  -485,   296,   297,
    -485,   163,   353,   309,   295,  -485,  -485,  -485,   385,  -485,
    -485,   299,   392,   298,    73,  -485,  -485,  -485,   300,   303,
     -93,  -485,   302,   292,   364,  -485,   306,   386,    79,   260,
    -485,  -485,  -485,  -485,  -485,  -485,  -485,   308,  -485,  -485,
     310,   311,   419,   386,  -485,   312,  -485,  -485,  -103,  -485,
    -485,  -485,    82,  -485,  -485,    92,  -485,  -485,   313,   314,
     315,     0,   317,   -78,  -485,   318,   403,   319,  -485,   260,
    -485,  -485,  -485,  -485,  -485,  -485,   320,   292,  -485,   -88,
     321,   399,  -485,   386,   323,   324,   -86,   127,  -485,   325,
     399,   399,   -84,  -485,  -485,   328,  -485,   329,   348,   168,
    -485,  -485,  -485,  -485,  -485,  -485,  -485,   326,   330,  -485,
    -485,   -77,  -485,   331,   332,  -485,   386,   334,   -72,  -485,
     335,   382,   333,   338,  -485,   339,   337,   399,   260,   367,
     336,   343,   386,   -70,  -485,   341,   342,   346,   347,   344,
     345,   349,   350,  -485,   400,   352,  -485,   -65,   354,  -485,
    -485,   -64,  -485,  -485,   399,   415,   355,  -485,   -54,  -485,
     292,   -74,  -485,   356,   -50,  -485,  -485,   358,   386,   357,
     386,  -485,   359,   260,  -485,   -49,  -485,  -485,   360,   362,
     363,   368,  -485,  -485,   366,   369,   399,  -485,   432,   370,
    -485,   -48,   371,   400,  -485,  -485,   -44,   373,   375,   376,
    -485,  -485,  -485,  -485,  -485,  -485,   -38,  -485,   399,  -485,
     399,  -485,   420,  -485,  -485,   372,   365,   374,   -37,   -32,
    -485,   377,  -485,  -485,   379,  -485,  -485,  -485,   422,   378,
    -485,  -485,  -485,   384,  -485,   383,   -19,   387,   380,   388,
     381,   389,  -485,  -485,  -485,   415,   -14,  -485,   390,   391,
    -485,    -8,   114,   393,  -485,  -485,  -485,  -485,  -485,  -485,
     394,   437,   395,  -485,     1,  -485,  -485,  -485,  -485,   396,
     398,     3,  -485,   397,  -485,   447,     5,   402,  -485,  -485,
    -485,   401,  -485,   404,    11,  -485,   405,  -485,    12,  -485,
     451,   406,   408,  -485,  -485,   118,  -485,   409,  -485
};

/* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
   Performed when YYTABLE does not specify something else to do.  Zero
   means the default is an error.  */
static const yytype_int16 yydefact[] =
{
       4,     0,    36,     1,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     3,     5,     6,     7,
       8,     9,    10,    11,    12,    13,    14,    15,    16,   319,
     267,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     2,    37,     0,     0,    33,    34,
      35,    32,    18,    17,    26,    19,    20,    21,    27,    28,
      29,    30,    31,    23,    24,    22,    25,   321,     0,    40,
      63,     0,     0,   266,     0,    38,     0,   239,   268,   323,
     318,   320,     0,     0,    66,     0,     0,     0,    42,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   237,   238,   240,   241,   242,   243,   244,   245,
     246,   247,   248,   249,   250,   251,   271,   325,     0,     0,
       0,     0,    83,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   134,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   200,     0,   212,
     213,     0,     0,   163,   202,   206,     0,     0,     0,     0,
       0,     0,     0,     0,    64,    69,    85,    93,    65,    67,
      68,    70,    71,    72,    73,    74,   117,   118,   119,    75,
      76,    77,    78,    79,    80,    81,    82,    84,    86,    87,
     193,   194,   195,   196,   197,    88,    89,    90,    91,    92,
      94,    95,    96,    97,    98,    99,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   265,     0,     0,
       0,     0,     0,    48,     0,     0,    39,    41,    43,    44,
      45,    52,    53,    54,    46,    47,    49,     0,     0,     0,
       0,     0,     0,     0,   111,   112,     0,     0,     0,     0,
       0,     0,     0,     0,   139,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   115,     0,     0,   210,   211,
       0,   217,   220,   129,     0,     0,     0,   125,   230,     0,
       0,     0,     0,     0,     0,   252,   253,   254,   255,   256,
     257,   258,   259,   260,   261,   262,     0,     0,     0,     0,
       0,     0,     0,     0,   309,   301,     0,   269,   284,   281,
     282,   298,   288,   277,   270,   272,   273,   274,   283,   275,
     289,   290,   291,   276,   297,   299,   278,   322,     0,   324,
       0,     0,     0,     0,     0,    51,    57,    56,    55,    60,
     100,   101,     0,     0,     0,   115,   116,   120,   121,   130,
     131,   132,   133,   136,   137,   138,   143,   146,   147,   148,
     150,   151,   149,   152,     0,   156,   169,   168,   177,     0,
     192,   198,     0,     0,   208,   115,   215,   216,     0,     0,
       0,     0,     0,     0,     0,     0,   231,   232,   233,   234,
     235,   236,   263,   230,     0,     0,     0,   287,     0,     0,
     296,   316,     0,     0,     0,    50,    58,    59,     0,    62,
     105,     0,     0,     0,     0,   140,   141,   142,     0,     0,
       0,   176,     0,   177,     0,   199,     0,     0,     0,     0,
     223,   225,   218,   219,   221,   222,   126,     0,   165,   166,
       0,     0,     0,     0,   122,     0,   229,   228,     0,   300,
     279,   280,     0,   292,   293,     0,   314,   315,     0,     0,
       0,     0,     0,     0,   105,     0,     0,     0,   110,     0,
     154,   159,   153,   155,   157,   182,     0,   177,   187,     0,
       0,     0,   209,     0,     0,     0,     0,     0,   105,     0,
       0,     0,     0,   264,   285,     0,   294,     0,     0,     0,
     105,   330,   327,   329,   328,   331,   332,     0,     0,   104,
     103,     0,   105,     0,     0,   109,     0,     0,     0,   182,
       0,   172,     0,     0,   105,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   105,     0,     0,     0,     0,     0,
       0,     0,     0,   307,     0,     0,   303,     0,     0,    61,
     106,     0,   105,   102,     0,     0,   181,   175,     0,   185,
     177,     0,   114,     0,     0,   105,   201,     0,     0,     0,
       0,   128,     0,     0,   204,     0,   203,   207,     0,     0,
       0,     0,   105,   105,   304,     0,     0,   302,     0,     0,
     107,     0,     0,     0,   180,   178,     0,     0,     0,     0,
     170,   171,   173,   174,   113,   144,     0,   214,     0,   105,
       0,   127,     0,   205,   124,     0,     0,     0,     0,     0,
     308,     0,   105,   305,     0,   326,   108,   135,     0,   184,
     179,   185,   190,     0,   145,     0,     0,     0,     0,     0,
       0,     0,   295,   310,   160,     0,     0,   105,     0,     0,
     183,     0,     0,     0,   224,   227,   226,   105,   164,   123,
       0,     0,     0,   161,     0,   105,   158,   186,   188,     0,
       0,     0,   286,     0,   306,     0,     0,     0,   191,   167,
     105,     0,   162,     0,     0,   105,     0,   311,     0,   189,
       0,     0,     0,   317,   115,     0,   312,     0,   313
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,
    -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,
    -485,  -485,   -68,  -485,  -485,  -485,   407,  -485,   417,  -485,
    -485,  -485,   418,  -485,  -485,  -485,  -485,  -485,  -485,  -485,
    -485,  -485,  -365,  -462,  -485,  -485,  -485,  -485,  -485,  -485,
    -344,   327,  -485,   340,   361,  -485,  -485,  -485,  -485,  -485,
    -485,   410,  -485,  -485,  -485,  -438,  -484,  -485,  -485,  -485,
    -485,    16,  -485,  -485,  -485,  -485,   -28,   -75,  -485,  -485,
    -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,  -420,
    -485,  -485,    18,   -87,  -485,  -485,  -485,  -485,  -485,   411,
    -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,
    -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,
    -485,  -485,  -485,   412,   150,  -485,  -485,  -485,  -485,  -485,
    -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,
    -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,
    -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,
    -485,  -485,  -485,  -485,  -485,  -485,  -107,  -485,  -485,  -485,
    -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,  -485,
    -485,  -485,  -485
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
       0,     1,     2,    16,    17,    18,    19,    20,    21,    65,
      22,    23,    24,    25,    26,    27,    28,    29,    30,    48,
      68,    83,    70,   118,   227,   228,   165,   230,   166,   338,
     232,   233,   167,   235,   236,    49,    76,    89,   168,   169,
     170,   171,   343,   463,   412,   466,   514,   172,   173,   246,
     372,   174,   175,   176,   177,   178,   384,   179,   380,   180,
     181,   182,   254,   356,   418,   481,   526,   183,   362,   184,
     185,   365,   420,   473,   517,   474,   544,   586,   649,   186,
     274,   440,   639,   187,   367,   188,   561,   601,   369,   422,
     424,   478,   518,   596,   521,   602,   652,   603,   189,   190,
     191,   192,   266,   193,   275,   442,   490,   194,   276,   195,
     196,   270,   197,   271,   378,   198,   379,   433,   434,   484,
     435,   485,   570,   199,   385,   200,   201,   202,   203,   204,
     205,    50,    85,   103,   104,   105,   106,   107,   108,   109,
     110,   111,   112,   113,   114,   115,   296,    51,    73,    86,
     218,   314,   315,   316,   317,   318,   452,   319,   320,   321,
     322,   455,   323,   324,   402,   545,   546,   584,   621,   325,
     401,   661,   690,   697,   458,   326,    44,    74,    81,    82,
     219,   329,   507
};

/* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule whose
   number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int16 yytable[] =
{
      75,   414,   511,   476,    78,   491,   535,   536,   427,   220,
     119,   120,    45,   221,   222,   121,   223,   224,   443,   501,
     502,   336,   430,   431,    46,   446,   533,   598,   599,   353,
     354,   428,    79,   493,   446,   471,     3,    80,   547,   447,
     472,   355,   522,   567,   530,   527,   537,   523,    31,   531,
     551,   538,   509,   509,    55,   510,   550,   520,   556,   600,
     509,   557,   564,   574,   483,   509,   509,    43,   588,   590,
     592,    54,   575,   432,   503,    32,   556,   504,   554,   595,
     509,   509,   509,   605,   613,   626,   629,    56,   505,   630,
     591,    33,   509,   509,   573,   634,   643,   225,   509,    52,
      53,   644,   623,   606,   516,    63,    64,    47,   128,   129,
     130,   509,    57,   297,   655,   135,   509,   244,   245,   663,
     618,   619,   629,   226,   635,   667,   637,    69,   506,    34,
     608,   509,   610,   509,   675,   509,   679,    35,   682,   145,
     597,   509,   509,    58,   687,   691,    36,   636,   268,   269,
     298,   299,   300,   301,   302,   303,   304,   415,   416,   417,
     646,   327,   328,   568,   305,    37,   360,   361,   157,    38,
     337,   339,    90,    91,    92,    93,    94,    95,    96,    97,
      98,    99,   100,   101,    59,   664,   376,   377,   392,   393,
     306,    60,   102,   425,   426,   671,   436,   437,   307,   438,
     439,   444,   445,   676,   456,   457,   468,   426,   612,   119,
     120,   386,   482,   426,   121,   494,   495,    39,   684,   122,
     123,   124,   125,   688,    40,   496,   497,   126,    41,   127,
     364,   542,   128,   129,   130,   131,   132,   133,   134,   135,
      42,    61,    66,   136,   137,   138,   139,   668,   669,   140,
     141,   696,   426,    62,    67,    69,   142,   143,    71,    72,
     404,    77,   144,   145,   146,   147,    84,   148,   149,   150,
     151,     4,     5,     6,     7,     8,     9,    10,    11,    12,
      13,    14,   152,   153,    15,    87,   154,   155,    88,   156,
     116,   117,   157,   206,   342,   207,   208,   158,   159,   160,
     161,   209,   210,   211,   212,   213,   441,   214,   215,   216,
     285,   217,   237,   366,   238,   162,   163,   239,   240,   241,
     411,   243,   164,   242,   247,   248,   249,   450,   451,   250,
     251,   252,   253,   255,   256,   257,   258,   259,   286,   260,
     261,   287,   262,   263,   264,   288,   265,   267,   289,   272,
     695,   273,   277,   278,   279,   280,   281,   282,   283,   284,
     290,   291,   292,   293,   294,   295,   364,   330,   331,   332,
     333,   334,   335,   340,   341,   344,   368,   346,   345,   347,
     348,   349,   350,   351,   352,   357,   358,   359,   363,   370,
     413,   371,   423,   374,   373,   459,   375,   381,   382,   383,
     387,   388,   389,   390,   391,   460,   394,   395,   396,   405,
     397,   398,   399,   462,   400,   403,   406,   407,   408,   532,
     409,   410,   419,   421,   449,   429,   453,   454,   465,   467,
     461,   464,   469,   470,   475,   477,   479,   480,   486,   489,
     513,   487,   492,   488,   541,   498,   499,   500,   508,   515,
     512,   525,   519,   524,   560,   528,   529,   534,   539,   540,
     549,   548,   569,   552,   585,   553,   555,   559,   563,   562,
     566,   565,   571,   572,   576,   577,   578,   579,   542,   580,
     581,   582,   583,   624,   589,   587,   638,   648,   673,   609,
     594,   607,   604,   616,   620,   611,   614,   615,   617,   681,
     641,   622,   640,   692,   627,   631,   625,   632,   633,   645,
     642,   647,   657,   650,   653,   543,   654,   659,   628,   660,
     656,   658,   665,   670,   666,   229,   677,   593,   674,   680,
     672,   678,   683,   685,   686,   231,   234,   558,   662,   693,
     694,   689,   698,   448,   651,   308,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   309,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   310,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   311,   312,
     313
};

static const yytype_int16 yycheck[] =
{
      68,   345,   464,   423,    72,   443,   490,   491,   373,    19,
      20,    21,    17,    23,    24,    25,    26,    27,   383,    19,
      20,    22,    82,    83,    29,   128,   488,   101,   102,    41,
      42,   375,   128,   136,   128,   128,     0,   133,   500,   133,
     133,    53,   130,   527,   130,   483,   130,   135,   131,   135,
     512,   135,   130,   130,   130,   133,   133,   477,   130,   133,
     130,   133,   524,   133,   429,   130,   130,    92,   133,   133,
     554,   128,   534,   133,    74,   131,   130,    77,   516,   133,
     130,   130,   130,   133,   133,   133,   130,   130,    88,   133,
     552,   131,   130,   130,   532,   133,   133,   107,   130,   128,
     129,   133,   586,   565,   469,    14,    15,   112,    43,    44,
      45,   130,   130,    48,   133,    50,   130,    41,    42,   133,
     582,   583,   130,   133,   608,   133,   610,   128,   128,   131,
     568,   130,   570,   130,   133,   130,   133,   131,   133,    74,
     560,   130,   130,   130,   133,   133,   131,   609,    41,    42,
      85,    86,    87,    88,    89,    90,    91,   104,   105,   106,
     622,   133,   134,   528,    99,   131,    58,    59,   103,   131,
     238,   239,   113,   114,   115,   116,   117,   118,   119,   120,
     121,   122,   123,   124,   128,   647,    41,    42,   133,   134,
     125,   130,   133,   133,   134,   657,   133,   134,   133,    17,
      18,   133,   134,   665,    41,    42,   133,   134,   573,    20,
      21,   279,   133,   134,    25,   133,   134,   131,   680,    30,
      31,    32,    33,   685,   131,   133,   134,    38,   131,    40,
      62,    63,    43,    44,    45,    46,    47,    48,    49,    50,
     131,   128,   130,    54,    55,    56,    57,   133,   134,    60,
      61,   133,   134,   128,   132,   128,    67,    68,   128,    84,
     328,   132,    73,    74,    75,    76,   132,    78,    79,    80,
      81,     3,     4,     5,     6,     7,     8,     9,    10,    11,
      12,    13,    93,    94,    16,   131,    97,    98,   132,   100,
     132,   132,   103,   131,    34,   131,   131,   108,   109,   110,
     111,   131,   131,   131,   131,   131,    77,   131,   131,   131,
     130,   132,   131,   128,   131,   126,   127,   131,   131,   131,
      35,   131,   133,   132,   131,   131,   131,   395,   396,   131,
     131,   131,   131,   131,   131,   131,   131,   131,   130,   132,
     131,   130,   132,   131,   131,   130,   132,   131,   130,   132,
     694,   132,   132,   132,   131,   131,   131,   131,   131,   131,
     130,   130,   130,   130,   130,   130,    62,   131,   131,   131,
     131,   131,   130,   130,   130,   130,    69,   130,   132,   130,
     130,   130,   130,   130,   130,   130,   130,   130,   130,   130,
      39,   130,    70,   130,   132,    42,   132,   132,   132,   132,
     130,   130,   130,   130,   130,    96,   131,   131,   131,   130,
     132,   131,   131,    28,   132,   132,   130,   130,   130,   487,
     130,   132,   131,   131,   130,   132,   130,   130,    36,   131,
     135,   132,   132,   130,   132,    71,   130,    51,   130,    20,
      37,   131,   130,   132,    96,   132,   132,   132,   131,   130,
     132,    52,   132,   132,    72,   132,   132,   132,   130,   130,
     130,   135,    95,   132,    64,   133,   132,   132,   130,   136,
     133,   132,   136,   130,   133,   133,   130,   130,    63,   135,
     135,   132,   132,    51,   130,   133,    66,    65,    51,   132,
     135,   133,   136,   130,   128,   136,   136,   135,   130,    52,
     135,   132,   130,    52,   133,   132,   136,   132,   132,   132,
     136,   132,   132,   135,   130,   499,   133,   136,   593,   130,
     133,   133,   132,   130,   133,   118,   130,   555,   133,   132,
     136,   133,   130,   132,   130,   118,   118,   519,   645,   133,
     132,   136,   133,   393,   631,   218,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   218,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   218,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   218,   218,
     218
};

/* YYSTOS[STATE-NUM] -- The symbol kind of the accessing symbol of
   state STATE-NUM.  */
static const yytype_int16 yystos[] =
{
       0,   138,   139,     0,     3,     4,     5,     6,     7,     8,
       9,    10,    11,    12,    13,    16,   140,   141,   142,   143,
     144,   145,   147,   148,   149,   150,   151,   152,   153,   154,
     155,   131,   131,   131,   131,   131,   131,   131,   131,   131,
     131,   131,   131,    92,   313,    17,    29,   112,   156,   172,
     268,   284,   128,   129,   128,   130,   130,   130,   130,   128,
     130,   128,   128,    14,    15,   146,   130,   132,   157,   128,
     159,   128,    84,   285,   314,   159,   173,   132,   159,   128,
     133,   315,   316,   158,   132,   269,   286,   131,   132,   174,
     113,   114,   115,   116,   117,   118,   119,   120,   121,   122,
     123,   124,   133,   270,   271,   272,   273,   274,   275,   276,
     277,   278,   279,   280,   281,   282,   132,   132,   160,    20,
      21,    25,    30,    31,    32,    33,    38,    40,    43,    44,
      45,    46,    47,    48,    49,    50,    54,    55,    56,    57,
      60,    61,    67,    68,    73,    74,    75,    76,    78,    79,
      80,    81,    93,    94,    97,    98,   100,   103,   108,   109,
     110,   111,   126,   127,   133,   163,   165,   169,   175,   176,
     177,   178,   184,   185,   188,   189,   190,   191,   192,   194,
     196,   197,   198,   204,   206,   207,   216,   220,   222,   235,
     236,   237,   238,   240,   244,   246,   247,   249,   252,   260,
     262,   263,   264,   265,   266,   267,   131,   131,   131,   131,
     131,   131,   131,   131,   131,   131,   131,   132,   287,   317,
      19,    23,    24,    26,    27,   107,   133,   161,   162,   163,
     164,   165,   167,   168,   169,   170,   171,   131,   131,   131,
     131,   131,   132,   131,    41,    42,   186,   131,   131,   131,
     131,   131,   131,   131,   199,   131,   131,   131,   131,   131,
     132,   131,   132,   131,   131,   132,   239,   131,    41,    42,
     248,   250,   132,   132,   217,   241,   245,   132,   132,   131,
     131,   131,   131,   131,   131,   130,   130,   130,   130,   130,
     130,   130,   130,   130,   130,   130,   283,    48,    85,    86,
      87,    88,    89,    90,    91,    99,   125,   133,   188,   190,
     191,   198,   236,   260,   288,   289,   290,   291,   292,   294,
     295,   296,   297,   299,   300,   306,   312,   133,   134,   318,
     131,   131,   131,   131,   131,   130,    22,   159,   166,   159,
     130,   130,    34,   179,   130,   132,   130,   130,   130,   130,
     130,   130,   130,    41,    42,    53,   200,   130,   130,   130,
      58,    59,   205,   130,    62,   208,   128,   221,    69,   225,
     130,   130,   187,   132,   130,   132,    41,    42,   251,   253,
     195,   132,   132,   132,   193,   261,   159,   130,   130,   130,
     130,   130,   133,   134,   131,   131,   131,   132,   131,   131,
     132,   307,   301,   132,   159,   130,   130,   130,   130,   130,
     132,    35,   181,    39,   187,   104,   105,   106,   201,   131,
     209,   131,   226,    70,   227,   133,   134,   179,   187,   132,
      82,    83,   133,   254,   255,   257,   133,   134,    17,    18,
     218,    77,   242,   179,   133,   134,   128,   133,   261,   130,
     159,   159,   293,   130,   130,   298,    41,    42,   311,    42,
      96,   135,    28,   180,   132,    36,   182,   131,   133,   132,
     130,   128,   133,   210,   212,   132,   226,    71,   228,   130,
      51,   202,   133,   179,   256,   258,   130,   131,   132,    20,
     243,   202,   130,   136,   133,   134,   133,   134,   132,   132,
     132,    19,    20,    74,    77,    88,   128,   319,   131,   130,
     133,   180,   132,    37,   183,   130,   179,   211,   229,   132,
     226,   231,   130,   135,   132,    52,   203,   202,   132,   132,
     130,   135,   159,   180,   132,   203,   203,   130,   135,   130,
     130,    96,    63,   208,   213,   302,   303,   180,   135,   130,
     133,   180,   132,   133,   202,   132,   130,   133,   229,   132,
      72,   223,   136,   130,   180,   132,   133,   203,   179,    95,
     259,   136,   130,   202,   133,   180,   133,   133,   130,   130,
     135,   135,   132,   132,   304,    64,   214,   133,   133,   130,
     133,   180,   203,   213,   135,   133,   230,   226,   101,   102,
     133,   224,   232,   234,   136,   133,   180,   133,   202,   132,
     202,   136,   179,   133,   136,   135,   130,   130,   180,   180,
     128,   305,   132,   203,    51,   136,   133,   133,   214,   130,
     133,   132,   132,   132,   133,   203,   180,   203,    66,   219,
     130,   135,   136,   133,   133,   132,   180,   132,    65,   215,
     135,   230,   233,   130,   133,   133,   133,   132,   133,   136,
     130,   308,   303,   133,   180,   132,   133,   133,   133,   134,
     130,   180,   136,    51,   133,   133,   180,   130,   133,   133,
     132,    52,   133,   130,   180,   132,   130,   133,   180,   136,
     309,   133,    52,   133,   132,   187,   133,   310,   133
};

/* YYR1[RULE-NUM] -- Symbol kind of the left-hand side of rule RULE-NUM.  */
static const yytype_int16 yyr1[] =
{
       0,   137,   138,   139,   139,   140,   140,   140,   140,   140,
     140,   140,   140,   140,   140,   140,   140,   141,   141,   142,
     143,   144,   145,   146,   146,   147,   148,   149,   150,   151,
     152,   153,   154,   155,   155,   155,   155,   157,   158,   156,
     159,   160,   160,   161,   161,   161,   161,   161,   161,   161,
     162,   163,   164,   164,   164,   165,   166,   166,   167,   168,
     169,   170,   171,   173,   172,   174,   174,   175,   175,   175,
     175,   175,   175,   175,   175,   175,   175,   175,   175,   175,
     175,   175,   175,   175,   175,   175,   175,   175,   175,   175,
     175,   175,   175,   175,   175,   175,   175,   175,   175,   175,
     176,   177,   178,   179,   180,   180,   181,   182,   183,   184,
     185,   186,   186,   187,   187,   187,   188,   189,   189,   189,
     190,   191,   192,   193,   193,   193,   194,   195,   195,   195,
     196,   197,   197,   197,   199,   198,   200,   200,   200,   200,
     201,   201,   201,   201,   202,   203,   204,   204,   204,   204,
     205,   205,   206,   207,   208,   209,   209,   211,   210,   212,
     213,   214,   215,   217,   216,   218,   218,   219,   220,   221,
     222,   223,   223,   224,   224,   225,   226,   226,   227,   228,
     229,   229,   229,   230,   230,   230,   231,   231,   232,   233,
     233,   234,   235,   235,   235,   235,   235,   235,   236,   237,
     239,   238,   241,   240,   242,   243,   245,   244,   246,   247,
     248,   248,   248,   250,   249,   251,   251,   251,   252,   253,
     253,   254,   254,   256,   255,   258,   257,   259,   260,   261,
     261,   262,   263,   264,   265,   266,   267,   268,   269,   269,
     270,   270,   270,   270,   270,   270,   270,   270,   270,   270,
     270,   270,   271,   272,   273,   274,   275,   276,   277,   278,
     279,   280,   281,   282,   283,   283,   284,   284,   286,   285,
     287,   287,   288,   288,   288,   288,   288,   288,   288,   289,
     290,   291,   291,   291,   291,   292,   293,   293,   294,   294,
     294,   294,   295,   296,   297,   298,   298,   299,   299,   299,
     299,   301,   300,   302,   302,   303,   304,   304,   305,   307,
     308,   309,   310,   306,   311,   311,   311,   312,   313,   313,
     314,   314,   315,   316,   317,   317,   318,   319,   319,   319,
     319,   319,   319
};

/* YYR2[RULE-NUM] -- Number of symbols on the right-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr2[] =
{
       0,     2,     3,     2,     0,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     3,     3,     3,
       3,     3,     3,     1,     1,     3,     3,     3,     3,     3,
       3,     3,     2,     2,     2,     2,     0,     0,     0,     7,
       1,     2,     0,     1,     1,     1,     1,     1,     1,     1,
       3,     3,     1,     1,     1,     3,     1,     1,     3,     3,
       3,     6,     3,     0,     6,     2,     0,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       3,     3,     7,     4,     2,     0,     4,     4,     4,     6,
       5,     1,     1,     6,     5,     0,     3,     1,     1,     1,
       3,     3,     4,     8,     6,     0,     4,     6,     5,     0,
       3,     3,     3,     3,     0,     9,     1,     1,     1,     0,
       1,     1,     1,     0,     4,     4,     3,     3,     3,     3,
       1,     1,     3,     5,     3,     2,     0,     0,     7,     1,
       4,     4,     4,     0,    10,     1,     1,     4,     3,     1,
       8,     2,     0,     1,     1,     5,     1,     0,     5,     5,
       3,     2,     0,     3,     2,     0,     6,     0,     4,     6,
       0,     5,     3,     1,     1,     1,     1,     1,     3,     4,
       0,     7,     0,     7,     4,     4,     0,     7,     3,     5,
       1,     1,     0,     0,     8,     1,     1,     0,     4,     2,
       0,     1,     1,     0,     7,     0,     7,     4,     4,     2,
       0,     3,     3,     3,     3,     3,     3,     5,     2,     0,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     3,     3,     3,     3,     3,     3,     3,     3,
       3,     3,     3,     4,     4,     0,     2,     0,     0,     6,
       2,     0,     1,     1,     1,     1,     1,     1,     1,     3,
       3,     1,     1,     1,     1,     4,     8,     0,     1,     1,
       1,     1,     3,     3,     4,     6,     0,     1,     1,     1,
       3,     0,     6,     1,     2,     3,     5,     0,     1,     0,
       0,     0,     0,    20,     1,     1,     0,    15,     4,     0,
       2,     0,     5,     1,     2,     0,     7,     1,     1,     1,
       1,     1,     1
};


enum { YYENOMEM = -2 };

#define yyerrok         (yyerrstatus = 0)
#define yyclearin       (yychar = ITF_EMPTY)

#define YYACCEPT        goto yyacceptlab
#define YYABORT         goto yyabortlab
#define YYERROR         goto yyerrorlab
#define YYNOMEM         goto yyexhaustedlab


#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)                                    \
  do                                                              \
    if (yychar == ITF_EMPTY)                                        \
      {                                                           \
        yychar = (Token);                                         \
        yylval = (Value);                                         \
        YYPOPSTACK (yylen);                                       \
        yystate = *yyssp;                                         \
        goto yybackup;                                            \
      }                                                           \
    else                                                          \
      {                                                           \
        yyerror (&yylloc, YY_("syntax error: cannot back up")); \
        YYERROR;                                                  \
      }                                                           \
  while (0)

/* Backward compatibility with an undocumented macro.
   Use ITF_error or ITF_UNDEF. */
#define YYERRCODE ITF_UNDEF

/* YYLLOC_DEFAULT -- Set CURRENT to span from RHS[1] to RHS[N].
   If N is 0, then set CURRENT to the empty location which ends
   the previous symbol: RHS[0] (always defined).  */

#ifndef YYLLOC_DEFAULT
# define YYLLOC_DEFAULT(Current, Rhs, N)                                \
    do                                                                  \
      if (N)                                                            \
        {                                                               \
          (Current).first_line   = YYRHSLOC (Rhs, 1).first_line;        \
          (Current).first_column = YYRHSLOC (Rhs, 1).first_column;      \
          (Current).last_line    = YYRHSLOC (Rhs, N).last_line;         \
          (Current).last_column  = YYRHSLOC (Rhs, N).last_column;       \
        }                                                               \
      else                                                              \
        {                                                               \
          (Current).first_line   = (Current).last_line   =              \
            YYRHSLOC (Rhs, 0).last_line;                                \
          (Current).first_column = (Current).last_column =              \
            YYRHSLOC (Rhs, 0).last_column;                              \
        }                                                               \
    while (0)
#endif

#define YYRHSLOC(Rhs, K) ((Rhs)[K])


/* Enable debugging if requested.  */
#if ITF_DEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)                        \
do {                                            \
  if (yydebug)                                  \
    YYFPRINTF Args;                             \
} while (0)


/* YYLOCATION_PRINT -- Print the location on the stream.
   This macro was not mandated originally: define only if we know
   we won't break user code: when these are the locations we know.  */

# ifndef YYLOCATION_PRINT

#  if defined YY_LOCATION_PRINT

   /* Temporary convenience wrapper in case some people defined the
      undocumented and private YY_LOCATION_PRINT macros.  */
#   define YYLOCATION_PRINT(File, Loc)  YY_LOCATION_PRINT(File, *(Loc))

#  elif defined ITF_LTYPE_IS_TRIVIAL && ITF_LTYPE_IS_TRIVIAL

/* Print *YYLOCP on YYO.  Private, do not rely on its existence. */

YY_ATTRIBUTE_UNUSED
static int
yy_location_print_ (FILE *yyo, YYLTYPE const * const yylocp)
{
  int res = 0;
  int end_col = 0 != yylocp->last_column ? yylocp->last_column - 1 : 0;
  if (0 <= yylocp->first_line)
    {
      res += YYFPRINTF (yyo, "%d", yylocp->first_line);
      if (0 <= yylocp->first_column)
        res += YYFPRINTF (yyo, ".%d", yylocp->first_column);
    }
  if (0 <= yylocp->last_line)
    {
      if (yylocp->first_line < yylocp->last_line)
        {
          res += YYFPRINTF (yyo, "-%d", yylocp->last_line);
          if (0 <= end_col)
            res += YYFPRINTF (yyo, ".%d", end_col);
        }
      else if (0 <= end_col && yylocp->first_column < end_col)
        res += YYFPRINTF (yyo, "-%d", end_col);
    }
  return res;
}

#   define YYLOCATION_PRINT  yy_location_print_

    /* Temporary convenience wrapper in case some people defined the
       undocumented and private YY_LOCATION_PRINT macros.  */
#   define YY_LOCATION_PRINT(File, Loc)  YYLOCATION_PRINT(File, &(Loc))

#  else

#   define YYLOCATION_PRINT(File, Loc) ((void) 0)
    /* Temporary convenience wrapper in case some people defined the
       undocumented and private YY_LOCATION_PRINT macros.  */
#   define YY_LOCATION_PRINT  YYLOCATION_PRINT

#  endif
# endif /* !defined YYLOCATION_PRINT */


# define YY_SYMBOL_PRINT(Title, Kind, Value, Location)                    \
do {                                                                      \
  if (yydebug)                                                            \
    {                                                                     \
      YYFPRINTF (stderr, "%s ", Title);                                   \
      yy_symbol_print (stderr,                                            \
                  Kind, Value, Location); \
      YYFPRINTF (stderr, "\n");                                           \
    }                                                                     \
} while (0)


/*-----------------------------------.
| Print this symbol's value on YYO.  |
`-----------------------------------*/

static void
yy_symbol_value_print (FILE *yyo,
                       yysymbol_kind_t yykind, YYSTYPE const * const yyvaluep, YYLTYPE const * const yylocationp)
{
  FILE *yyoutput = yyo;
  YY_USE (yyoutput);
  YY_USE (yylocationp);
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
                 yysymbol_kind_t yykind, YYSTYPE const * const yyvaluep, YYLTYPE const * const yylocationp)
{
  YYFPRINTF (yyo, "%s %s (",
             yykind < YYNTOKENS ? "token" : "nterm", yysymbol_name (yykind));

  YYLOCATION_PRINT (yyo, yylocationp);
  YYFPRINTF (yyo, ": ");
  yy_symbol_value_print (yyo, yykind, yyvaluep, yylocationp);
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
yy_reduce_print (yy_state_t *yyssp, YYSTYPE *yyvsp, YYLTYPE *yylsp,
                 int yyrule)
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
                       &yyvsp[(yyi + 1) - (yynrhs)],
                       &(yylsp[(yyi + 1) - (yynrhs)]));
      YYFPRINTF (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)          \
do {                                    \
  if (yydebug)                          \
    yy_reduce_print (yyssp, yyvsp, yylsp, Rule); \
} while (0)

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !ITF_DEBUG */
# define YYDPRINTF(Args) ((void) 0)
# define YY_SYMBOL_PRINT(Title, Kind, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !ITF_DEBUG */


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
            yysymbol_kind_t yykind, YYSTYPE *yyvaluep, YYLTYPE *yylocationp)
{
  YY_USE (yyvaluep);
  YY_USE (yylocationp);
  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yykind, yyvaluep, yylocationp);

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YY_USE (yykind);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}






/*----------.
| yyparse.  |
`----------*/

int
yyparse (void)
{
/* Lookahead token kind.  */
int yychar;


/* The semantic value of the lookahead symbol.  */
/* Default value used for initialization, for pacifying older GCCs
   or non-GCC compilers.  */
YY_INITIAL_VALUE (static YYSTYPE yyval_default;)
YYSTYPE yylval YY_INITIAL_VALUE (= yyval_default);

/* Location data for the lookahead symbol.  */
static YYLTYPE yyloc_default
# if defined ITF_LTYPE_IS_TRIVIAL && ITF_LTYPE_IS_TRIVIAL
  = { 1, 1, 1, 1 }
# endif
;
YYLTYPE yylloc = yyloc_default;

    /* Number of syntax errors so far.  */
    int yynerrs = 0;

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

    /* The location stack: array, bottom, top.  */
    YYLTYPE yylsa[YYINITDEPTH];
    YYLTYPE *yyls = yylsa;
    YYLTYPE *yylsp = yyls;

  int yyn;
  /* The return value of yyparse.  */
  int yyresult;
  /* Lookahead symbol kind.  */
  yysymbol_kind_t yytoken = YYSYMBOL_YYEMPTY;
  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;
  YYLTYPE yyloc;

  /* The locations where the error started and ended.  */
  YYLTYPE yyerror_range[3];



#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N), yylsp -= (N))

  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yychar = ITF_EMPTY; /* Cause a token to be read.  */

  yylsp[0] = yylloc;
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
        YYLTYPE *yyls1 = yyls;

        /* Each stack pointer address is followed by the size of the
           data in use in that stack, in bytes.  This used to be a
           conditional around just the two extra args, but that might
           be undefined if yyoverflow is a macro.  */
        yyoverflow (YY_("memory exhausted"),
                    &yyss1, yysize * YYSIZEOF (*yyssp),
                    &yyvs1, yysize * YYSIZEOF (*yyvsp),
                    &yyls1, yysize * YYSIZEOF (*yylsp),
                    &yystacksize);
        yyss = yyss1;
        yyvs = yyvs1;
        yyls = yyls1;
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
        YYSTACK_RELOCATE (yyls_alloc, yyls);
#  undef YYSTACK_RELOCATE
        if (yyss1 != yyssa)
          YYSTACK_FREE (yyss1);
      }
# endif

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;
      yylsp = yyls + yysize - 1;

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
  if (yychar == ITF_EMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token\n"));
      yychar = yylex (&yylval, &yylloc);
    }

  if (yychar <= ITF_EOF)
    {
      yychar = ITF_EOF;
      yytoken = YYSYMBOL_YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else if (yychar == ITF_error)
    {
      /* The scanner already issued an error message, process directly
         to error recovery.  But do not keep the error token as
         lookahead, it is too special and may lead us to an endless
         loop in error recovery. */
      yychar = ITF_UNDEF;
      yytoken = YYSYMBOL_YYerror;
      yyerror_range[1] = yylloc;
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
  *++yylsp = yylloc;

  /* Discard the shifted token.  */
  yychar = ITF_EMPTY;
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

  /* Default location. */
  YYLLOC_DEFAULT (yyloc, (yylsp - yylen), yylen);
  yyerror_range[1] = yyloc;
  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
  case 5: /* file_optional: tech  */
#line 137 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    CALLBACK(itfCallbacks->technology_cb, itfCallBackType::kTechnologyCbType, itfData->process_name);
  }
#line 2111 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 6: /* file_optional: global_temperature  */
#line 141 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    CALLBACK(itfCallbacks->global_temperature_cb, itfCallBackType::kGlobalTemperatureCbType, itfData->global_temperature);
  }
#line 2119 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 7: /* file_optional: background_er  */
#line 145 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    CALLBACK(itfCallbacks->background_er_cb, itfCallBackType::kBackgroundErCbType, itfData->background_er);
  }
#line 2127 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 8: /* file_optional: half_node_scale_factor  */
#line 149 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    CALLBACK(itfCallbacks->half_node_scale_factor_cb, itfCallBackType::kHalfNodeScaleFactorCbType, itfData->half_node_scale_factor);
  }
#line 2135 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 9: /* file_optional: use_si_density  */
#line 153 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    CALLBACK(itfCallbacks->use_si_density_cb, itfCallBackType::kUseSiDensityCbType, itfData->use_si_density);
  }
#line 2143 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 10: /* file_optional: drop_factor_lateral_spacing  */
#line 157 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    CALLBACK(itfCallbacks->drop_factor_lateral_spacing_cb, itfCallBackType::kDropFactorLateralSpacingCbType, itfData->drop_factor_lateral_spacing);
  }
#line 2151 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 11: /* file_optional: process_foundry  */
#line 161 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    CALLBACK(itfCallbacks->process_foundry_cb, itfCallBackType::kProcessFoundryCbType, itfData->process_foundry);
  }
#line 2159 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 12: /* file_optional: process_node  */
#line 165 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    CALLBACK(itfCallbacks->process_node_cb, itfCallBackType::kProcessNodeCbType, itfData->process_node);
  }
#line 2167 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 13: /* file_optional: process_type  */
#line 169 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    CALLBACK(itfCallbacks->process_type_cb, itfCallBackType::kProcessTypeCbType, itfData->process_type);
  }
#line 2175 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 14: /* file_optional: process_version  */
#line 173 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    CALLBACK(itfCallbacks->process_version_cb, itfCallBackType::kProcessVersionCbType, itfData->process_version);
  }
#line 2183 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 15: /* file_optional: process_corner  */
#line 177 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    CALLBACK(itfCallbacks->process_corner_cb, itfCallBackType::kProcessCornerCbType, itfData->process_corner);
  }
#line 2191 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 16: /* file_optional: reference_direction  */
#line 181 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    CALLBACK(itfCallbacks->reference_direction_cb, itfCallBackType::kReferenceDirectionCbType, itfData->reference_direction);
  }
#line 2199 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 17: /* tech: K_TECHNOLOGY '=' PROCESS_NAME  */
#line 188 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    ITF_STR_CPY(itfData->process_name, (yyvsp[0].string));
  }
#line 2207 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 18: /* tech: K_TECHNOLOGY '=' KEYWORD  */
#line 192 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    ITF_STR_CPY(itfData->process_name, (yyvsp[0].string));
  }
#line 2215 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 19: /* global_temperature: K_GLOBAL_TEMPERATURE '=' NUMBER  */
#line 199 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->has_global_temperature = 1;
    itfData->global_temperature = (yyvsp[0].dval);
  }
#line 2224 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 20: /* background_er: K_BACKGROUND_ER '=' NUMBER  */
#line 207 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->has_background_er = 1;
    itfData->background_er = (yyvsp[0].dval);
  }
#line 2233 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 21: /* half_node_scale_factor: K_HALF_NODE_SCALE_FACTOR '=' NUMBER  */
#line 215 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->has_half_node_scale_factor = 1;
    itfData->half_node_scale_factor = (yyvsp[0].dval);
  }
#line 2242 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 22: /* use_si_density: K_USE_SI_DENSITY '=' use_si_density_value  */
#line 223 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->has_use_si_density = 1;
  }
#line 2250 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 23: /* use_si_density_value: K_YES  */
#line 229 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
        { itfData->use_si_density = 1; }
#line 2256 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 24: /* use_si_density_value: K_NO  */
#line 230 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
        { itfData->use_si_density = 0; }
#line 2262 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 25: /* drop_factor_lateral_spacing: K_DROP_FACTOR_LATERAL_SPACING '=' NUMBER  */
#line 235 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->has_drop_factor_lateral_spacing = 1;
    itfData->drop_factor_lateral_spacing = (yyvsp[0].dval);
  }
#line 2271 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 33: /* x_eol: x_eol dielectric  */
#line 272 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    CALLBACK(itfCallbacks->dielectric_cb, itfCallBackType::kDielectricCbType, &itfData->dielectric);
    itfData->dielectric.clear();
  }
#line 2280 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 34: /* x_eol: x_eol conductor  */
#line 277 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    CALLBACK(itfCallbacks->conductor_cb, itfCallBackType::kConductorCbType, &itfData->conductor);
    itfData->conductor.clear();
  }
#line 2289 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 37: /* $@1: %empty  */
#line 287 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    v_flag_dielectric = 1;
  }
#line 2297 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 38: /* $@2: %empty  */
#line 291 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->dielectric.set_dielectric_name(v_layer_name);
  }
#line 2305 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 39: /* dielectric: K_DIELECTRIC $@1 layer_name $@2 '{' dielectric_properties '}'  */
#line 297 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    v_flag_dielectric = 0;
  }
#line 2313 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 40: /* layer_name: KEYWORD  */
#line 303 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
          { ITF_STR_CPY(v_layer_name, (yyvsp[0].string)); }
#line 2319 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 44: /* dielectric_property: thickness  */
#line 313 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
                        { itfData->dielectric.set_thickness(v_thickness); }
#line 2325 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 46: /* dielectric_property: associated_conductor  */
#line 316 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->dielectric.set_associated_conductor(v_layer_name);
  }
#line 2333 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 48: /* dielectric_property: K_IS_CONFORMAL  */
#line 321 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->dielectric.set_is_conformal();
  }
#line 2341 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 50: /* er: K_ER '=' NUMBER  */
#line 329 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  { itfData->dielectric.set_er((yyvsp[0].dval)); }
#line 2347 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 51: /* thickness: K_THICKNESS '=' NUMBER  */
#line 334 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  { v_thickness = (yyvsp[0].dval); }
#line 2353 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 52: /* diel_measured_from: measured_from  */
#line 338 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
                { itfData->dielectric.set_measured_from(v_measured_from); }
#line 2359 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 53: /* diel_measured_from: sw_t  */
#line 339 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
                { itfData->dielectric.set_sw_t(v_sw_t); }
#line 2365 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 54: /* diel_measured_from: tw_t  */
#line 340 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
                { itfData->dielectric.set_tw_t(v_tw_t); }
#line 2371 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 56: /* measured_from_value: layer_name  */
#line 348 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
                { ITF_STR_CPY(v_measured_from, v_layer_name); }
#line 2377 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 57: /* measured_from_value: K_TOP_OF_CHIP  */
#line 349 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
                { ITF_STR_CPY(v_measured_from, "TOP_OF_CHIP"); }
#line 2383 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 58: /* sw_t: K_SW_T '=' NUMBER  */
#line 353 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
                    { v_sw_t = (yyvsp[0].dval); }
#line 2389 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 59: /* tw_t: K_TW_T '=' NUMBER  */
#line 357 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
                    { v_tw_t = (yyvsp[0].dval); }
#line 2395 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 61: /* damage: K_DAMAGE_THICKNESS '=' NUMBER K_DAMAGE_ER '=' NUMBER  */
#line 367 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->dielectric.set_damage_thickness((yyvsp[-3].dval));
    itfData->dielectric.set_damage_er((yyvsp[0].dval));
  }
#line 2404 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 62: /* bw_t: K_BW_T '=' NUMBER  */
#line 375 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {

  }
#line 2412 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 63: /* $@3: %empty  */
#line 382 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->conductor.set_conductor_name(v_layer_name);
  }
#line 2420 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 69: /* conductor_property: thickness  */
#line 398 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
            { itfData->conductor.set_thickness(v_thickness); }
#line 2426 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 73: /* conductor_property: t0  */
#line 402 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
     { itfData->conductor.set_t0(v_t0); }
#line 2432 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 78: /* conductor_property: etch_vs_width_and_spacing  */
#line 408 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->conductor.add_etch_vws(v_etch_effect_type, v_lut);
    ITF_FREE(v_etch_effect_type);
    v_lut.clear();
    v_is_lut_working = 0;
  }
#line 2443 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 83: /* conductor_property: K_IS_PLANAR  */
#line 418 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
              { itfData->conductor.set_is_planar(); }
#line 2449 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 85: /* conductor_property: measured_from  */
#line 420 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
                { itfData->conductor.set_measured_from(v_measured_from); }
#line 2455 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 93: /* conductor_property: associated_conductor  */
#line 428 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
                       { }
#line 2461 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 100: /* wmin: K_WMIN '=' NUMBER  */
#line 439 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->conductor.set_wmin((yyvsp[0].dval));
  }
#line 2469 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 101: /* smin: K_SMIN '=' NUMBER  */
#line 446 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->conductor.set_smin((yyvsp[0].dval));
  }
#line 2477 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 103: /* spacings: K_SPACINGS '{' float_list '}'  */
#line 462 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    if (v_is_lut_working) {
      v_lut.set_data_list<float>("SPACINGS", v_float_list);
    } else {
      itfData->conductor.set_air_gap_spacings(v_float_list);
    }
    v_float_list.clear();
  }
#line 2490 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 104: /* float_list: float_list NUMBER  */
#line 474 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    v_float_list.push_back((yyvsp[0].dval));
  }
#line 2498 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 106: /* air_gap_widths: K_AIR_GAP_WIDTHS '{' float_list '}'  */
#line 482 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->conductor.set_air_gap_widths(v_float_list);
    v_float_list.clear();
  }
#line 2507 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 107: /* air_gap_thicknesses: K_AIR_GAP_THICKNESSES '{' float_list '}'  */
#line 490 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->conductor.set_air_gap_thicknesses(v_float_list);
    v_float_list.clear();
  }
#line 2516 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 108: /* air_gap_bottom_heights: K_AIR_GAP_BOTTOM_HEIGHTS '{' float_list '}'  */
#line 498 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->conductor.set_air_gap_bottom_heights(v_float_list);
    v_float_list.clear();
  }
#line 2525 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 109: /* bottom_dielectric_property: K_BOTTOM_DIELECTRIC_THICKNESS '=' NUMBER K_BOTTOM_DIELECTRIC_ER '=' NUMBER  */
#line 507 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->conductor.set_bottom_dielectric_thickness((yyvsp[-3].dval));
    itfData->conductor.set_bottom_dielectric_er((yyvsp[0].dval));
  }
#line 2534 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 110: /* bottom_thickness_vs_si_width: K_BOTTOM_THICKNESS_VS_SI_WIDTH bottom_thickness_vs_si_width_type '{' float_pair_list '}'  */
#line 516 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->conductor.get_bottom_thickness_vs_si_width().set_sr_list(v_float_pair_list);
    v_float_pair_list.clear();
  }
#line 2543 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 111: /* bottom_thickness_vs_si_width_type: K_RESISTIVE_ONLY  */
#line 524 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->conductor.get_bottom_thickness_vs_si_width().set_type("RESISTIVE_ONLY");
  }
#line 2551 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 112: /* bottom_thickness_vs_si_width_type: K_CAPACITIVE_ONLY  */
#line 528 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->conductor.get_bottom_thickness_vs_si_width().set_type("CAPACITIVE_ONLY");
  }
#line 2559 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 113: /* float_pair_list: float_pair_list '(' NUMBER ',' NUMBER ')'  */
#line 535 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  { v_float_pair_list.push_back({(yyvsp[-3].dval), (yyvsp[-1].dval)}); }
#line 2565 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 114: /* float_pair_list: float_pair_list '(' NUMBER NUMBER ')'  */
#line 537 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  { v_float_pair_list.push_back({(yyvsp[-2].dval), (yyvsp[-1].dval)}); }
#line 2571 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 116: /* t0: K_T0 '=' NUMBER  */
#line 543 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    v_t0 = (yyvsp[0].dval);
  }
#line 2579 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 117: /* crt_stmt: crt1  */
#line 549 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
        { itfData->conductor.set_crt1(v_crt1); }
#line 2585 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 118: /* crt_stmt: crt2  */
#line 550 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
        { itfData->conductor.set_crt2(v_crt2); }
#line 2591 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 120: /* crt1: K_CRT1 '=' NUMBER  */
#line 556 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    v_crt1 = (yyvsp[0].dval);
  }
#line 2599 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 121: /* crt2: K_CRT2 '=' NUMBER  */
#line 563 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    v_crt2 = (yyvsp[0].dval);
  }
#line 2607 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 123: /* siw_crt1_crt2_list: siw_crt1_crt2_list '(' NUMBER ',' NUMBER ',' NUMBER ')'  */
#line 577 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->conductor.add_siw_crt1_crt2((yyvsp[-5].dval), (yyvsp[-3].dval), (yyvsp[-1].dval));
  }
#line 2615 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 124: /* siw_crt1_crt2_list: siw_crt1_crt2_list '(' NUMBER NUMBER NUMBER ')'  */
#line 581 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->conductor.add_siw_crt1_crt2((yyvsp[-3].dval), (yyvsp[-2].dval), (yyvsp[-1].dval));
  }
#line 2623 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 127: /* s_w_list: s_w_list '(' NUMBER ',' NUMBER ')'  */
#line 595 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->conductor.add_density_box_weight(int((yyvsp[-3].dval)), (yyvsp[-1].dval));
  }
#line 2631 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 128: /* s_w_list: s_w_list '(' NUMBER NUMBER ')'  */
#line 599 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->conductor.add_density_box_weight(int((yyvsp[-2].dval)), (yyvsp[-1].dval));
  }
#line 2639 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 130: /* drop_factor: K_DROP_FACTOR '=' NUMBER  */
#line 607 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->conductor.set_drop_factor((yyvsp[0].dval));
  }
#line 2647 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 131: /* etch_stmt: K_ETCH '=' NUMBER  */
#line 614 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  { itfData->conductor.set_etch((yyvsp[0].dval)); }
#line 2653 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 132: /* etch_stmt: K_CAPACITIVE_ONLY_ETCH '=' NUMBER  */
#line 616 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  { itfData->conductor.set_capacitive_only_etch((yyvsp[0].dval)); }
#line 2659 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 133: /* etch_stmt: K_RESISTIVE_ONLY_ETCH '=' NUMBER  */
#line 618 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  { itfData->conductor.set_resistive_only_etch((yyvsp[0].dval)); }
#line 2665 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 134: /* $@4: %empty  */
#line 623 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    v_lut.set_names("WIDTHS", "SPACINGS", "VALUES");
    v_is_lut_working = 1;
  }
#line 2674 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 136: /* etch_effect_type: K_RESISTIVE_ONLY  */
#line 637 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
                    { ITF_STR_CPY(v_etch_effect_type, "RESISTIVE_ONLY"); }
#line 2680 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 137: /* etch_effect_type: K_CAPACITIVE_ONLY  */
#line 638 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
                    { ITF_STR_CPY(v_etch_effect_type, "CAPACITIVE_ONLY"); }
#line 2686 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 138: /* etch_effect_type: K_ETCH_FROM_TOP  */
#line 639 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
                    { ITF_STR_CPY(v_etch_effect_type, "ETCH_FROM_TOP"); }
#line 2692 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 144: /* widths: K_WIDTHS '{' float_list '}'  */
#line 652 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    v_lut.set_data_list<float>("WIDTHS", v_float_list);
    v_float_list.clear();
  }
#line 2701 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 145: /* values: K_VALUES '{' float_list '}'  */
#line 660 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    v_lut.set_data_list<float>("VALUES", v_float_list);
    v_float_list.clear();
  }
#line 2710 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 146: /* fill_stmt: K_FILL_RATIO '=' NUMBER  */
#line 668 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  { itfData->conductor.set_fill_ratio((yyvsp[0].dval)); }
#line 2716 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 147: /* fill_stmt: K_FILL_SPACING '=' NUMBER  */
#line 670 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  { itfData->conductor.set_fill_spacing((yyvsp[0].dval)); }
#line 2722 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 148: /* fill_stmt: K_FILL_WIDTH '=' NUMBER  */
#line 672 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  { itfData->conductor.set_fill_width((yyvsp[0].dval)); }
#line 2728 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 150: /* fill_type: K_GROUNDED  */
#line 678 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  { itfData->conductor.set_fill_type("GROUNDED"); }
#line 2734 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 151: /* fill_type: K_FLOATING  */
#line 680 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  { itfData->conductor.set_fill_type("FLOATING"); }
#line 2740 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 152: /* gate_to_contact_smin: K_GATE_TO_CONTACT_SMIN '=' NUMBER  */
#line 685 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->conductor.set_gate_to_contact_smin((yyvsp[0].dval));
  }
#line 2748 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 153: /* gate_to_diffusion_cap: K_GATE_TO_DIFFUSION_CAP '{' number_of_tables model_list '}'  */
#line 695 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->conductor.get_gate_to_diffusion_cap().set_number_of_tables(v_number_of_tables);
  }
#line 2756 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 154: /* number_of_tables: K_NUMBER_OF_TABLES '=' NUMBER  */
#line 702 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    v_number_of_tables = int((yyvsp[0].dval));
  }
#line 2764 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 157: /* $@5: %empty  */
#line 714 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    v_lut.set_names("GATE_TO_CONTACT_SPACINGS", "CONTACT_TO_CONTACT_SPACINGS", "CAPS_PER_MICRON");
    v_is_lut_working = 1;
  }
#line 2773 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 158: /* model: model_name $@5 '{' contact_to_contact_spacings gate_to_contact_spacings caps_per_micron '}'  */
#line 723 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->conductor.get_gate_to_diffusion_cap().add_model(v_model_name, v_lut);
    v_lut.clear();
    v_is_lut_working = 0;
  }
#line 2783 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 159: /* model_name: KEYWORD  */
#line 731 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
            { ITF_STR_CPY(v_model_name, (yyvsp[0].string)); }
#line 2789 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 160: /* contact_to_contact_spacings: K_CONTACT_TO_CONTACT_SPACINGS '{' float_list '}'  */
#line 736 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    v_lut.set_data_list<float>("CONTACT_TO_CONTACT_SPACINGS", v_float_list);
    v_float_list.clear();
  }
#line 2798 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 161: /* gate_to_contact_spacings: K_GATE_TO_CONTACT_SPACINGS '{' float_list '}'  */
#line 744 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    v_lut.set_data_list<float>("GATE_TO_CONTACT_SPACINGS", v_float_list);
    v_float_list.clear();
  }
#line 2807 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 162: /* caps_per_micron: K_CAPS_PER_MICRON '{' float_list '}'  */
#line 752 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    v_lut.set_data_list<float>("CAPS_PER_MICRON", v_float_list);
    v_float_list.clear();
  }
#line 2816 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 163: /* $@6: %empty  */
#line 760 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    v_lut.set_names("WIDTHS", "SPACINGS", "THICKNESS_CHANGES");
    v_is_lut_working = 1;
  }
#line 2825 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 164: /* ild_vs_width_and_spacing: K_ILD_VS_WIDTH_AND_SPACING $@6 '{' ild_diel_layer_token '=' layer_name widths spacings thickness_changes '}'  */
#line 770 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->conductor.set_ild_vws_title(v_layer_name);
    itfData->conductor.set_ild_vws_lut(v_lut);
    v_lut.clear();
    v_is_lut_working = 0;
  }
#line 2836 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 167: /* thickness_changes: K_THICKNESS_CHANGES '{' float_list '}'  */
#line 785 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    v_lut.set_data_list<float>("THICKNESS_CHANGES", v_float_list);
    v_float_list.clear();
  }
#line 2845 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 169: /* layer_type_value: KEYWORD  */
#line 796 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
          { itfData->conductor.set_layer_type((yyvsp[0].string)); }
#line 2851 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 175: /* density_polynomial_orders: K_DENSITY_POLYNOMIAL_ORDERS equal_op '{' int_comma_list '}'  */
#line 822 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->conductor.get_PBTV().set_density_polynomial_order(v_int_list);
    v_int_list.clear();
  }
#line 2860 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 178: /* width_polynomial_orders: K_WIDTH_POLYNOMIAL_ORDERS equal_op '{' int_comma_list '}'  */
#line 835 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->conductor.get_PBTV().set_width_polynomial_order(v_int_list);
    v_int_list.clear();
  }
#line 2869 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 179: /* width_ranges: K_WIDTH_RANGES equal_op '{' float_comma_list '}'  */
#line 843 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->conductor.get_PBTV().set_width_range(v_float_list);
    v_float_list.clear();
  }
#line 2878 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 180: /* int_comma_list: int_comma_list NUMBER ','  */
#line 850 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
                             { v_int_list.push_back(int((yyvsp[-1].dval))); }
#line 2884 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 181: /* int_comma_list: int_comma_list NUMBER  */
#line 851 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
                             { v_int_list.push_back(int((yyvsp[0].dval))); }
#line 2890 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 183: /* float_comma_list: float_comma_list NUMBER ','  */
#line 856 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
                              { v_float_list.push_back((yyvsp[-1].dval)); }
#line 2896 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 184: /* float_comma_list: float_comma_list NUMBER  */
#line 857 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
                              { v_float_list.push_back((yyvsp[0].dval)); }
#line 2902 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 186: /* polynomial_valueicients_lists: polynomial_valueicients_lists K_POLYNOMIAL_COEFFICIENTS equal_op '{' float_comma_list '}'  */
#line 866 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->conductor.get_PBTV().add_polynomial_coefficients(v_float_list);
    v_float_list.clear();
  }
#line 2911 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 189: /* tuple_3_list: tuple_3_list '(' NUMBER NUMBER NUMBER ')'  */
#line 882 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {

  }
#line 2919 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 191: /* thickness_bounds: K_THICKNESS_BOUNDS '{' NUMBER NUMBER '}'  */
#line 890 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {

  }
#line 2927 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 192: /* rpsq_stmt: K_RPSQ '=' NUMBER  */
#line 896 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
                    { itfData->conductor.set_rpsq((yyvsp[0].dval)); }
#line 2933 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 193: /* rpsq_stmt: rho  */
#line 897 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
                    { itfData->conductor.set_rho(v_rho); }
#line 2939 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 198: /* rho: K_RHO '=' NUMBER  */
#line 905 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
                   { v_rho = (yyvsp[0].dval); }
#line 2945 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 199: /* rpsq_vs_si_width: K_RPSQ_VS_SI_WIDTH '{' float_pair_list '}'  */
#line 912 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->conductor.set_rpsq_vs_si_width(v_float_pair_list);
    v_float_pair_list.clear();
  }
#line 2954 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 200: /* $@7: %empty  */
#line 920 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    v_lut.set_names("WIDTHS", "SPACINGS", "VALUES");
    v_is_lut_working = 1;
  }
#line 2963 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 201: /* rpsq_vs_width_and_spacing: K_RPSQ_VS_WIDTH_AND_SPACING $@7 '{' spacings widths values '}'  */
#line 929 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->conductor.set_rpsq_vws(v_lut);
    v_lut.clear();
    v_is_lut_working = 0;
  }
#line 2973 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 202: /* $@8: %empty  */
#line 938 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    v_lut.set_names("THICKNESS", "WIDTH", "VALUES");
    v_is_lut_working = 1;
  }
#line 2982 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 203: /* rho_vs_si_width_and_thickness: K_RHO_VS_SI_WIDTH_AND_THICKNESS $@8 '{' width_list thickness_list values '}'  */
#line 947 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->conductor.set_rho_v_siw_t(v_lut);
    v_lut.clear();
    v_is_lut_working = 0;
  }
#line 2992 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 204: /* width_list: K_WIDTH '{' float_list '}'  */
#line 956 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    v_lut.set_data_list<float>("WIDTH", v_float_list);
    v_float_list.clear();
  }
#line 3001 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 205: /* thickness_list: K_THICKNESS '{' float_list '}'  */
#line 964 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    v_lut.set_data_list<float>("THICKNESS", v_float_list);
    v_float_list.clear();
  }
#line 3010 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 206: /* $@9: %empty  */
#line 972 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    v_lut.set_names("WIDTHS", "SPACINGS", "VALUES");
    v_is_lut_working = 1;
  }
#line 3019 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 207: /* rho_vs_width_and_spacing: K_RHO_VS_WIDTH_AND_SPACING $@9 '{' spacings widths values '}'  */
#line 981 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->conductor.set_rho_vws(v_lut);
    v_lut.clear();
    v_is_lut_working = 0;
  }
#line 3029 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 208: /* side_tangent: K_SIDE_TANGENT '=' NUMBER  */
#line 990 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  { itfData->conductor.set_side_tangent((yyvsp[0].dval)); }
#line 3035 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 209: /* thickness_vs_density: K_THICKNESS_VS_DENSITY thickness_vs_density_type '{' float_pair_list '}'  */
#line 996 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->conductor.get_thickness_vs_density().set_dr_list(v_float_pair_list);
    v_float_pair_list.clear();
  }
#line 3044 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 210: /* thickness_vs_density_type: K_RESISTIVE_ONLY  */
#line 1004 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  { itfData->conductor.get_thickness_vs_density().set_type("RESISTIVE_ONLY"); }
#line 3050 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 211: /* thickness_vs_density_type: K_CAPACITIVE_ONLY  */
#line 1006 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  { itfData->conductor.get_thickness_vs_density().set_type("CAPACITIVE_ONLY"); }
#line 3056 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 213: /* $@10: %empty  */
#line 1012 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    v_lut.set_names("WIDTHS", "SPACINGS", "VALUES");
    v_is_lut_working = 1;
  }
#line 3065 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 214: /* thickness_vs_width_and_spacing: K_THICKNESS_VS_WIDTH_AND_SPACING $@10 thickness_vs_width_and_spacing_type '{' spacings widths values '}'  */
#line 1022 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->conductor.set_thickness_vws_lut(v_lut);
    v_lut.clear();
    v_is_lut_working = 0;
  }
#line 3075 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 215: /* thickness_vs_width_and_spacing_type: K_RESISTIVE_ONLY  */
#line 1031 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  { itfData->conductor.set_thickness_vws_title("RESISTIVE_ONLY"); }
#line 3081 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 216: /* thickness_vs_width_and_spacing_type: K_CAPACITIVE_ONLY  */
#line 1033 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  { itfData->conductor.set_thickness_vws_title("CAPACITIVE_ONLY"); }
#line 3087 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 223: /* $@11: %empty  */
#line 1055 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    v_lut.set_names("WIDTHS", "SPACINGS", "VALUES");
    v_is_lut_working = 1;
  }
#line 3096 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 224: /* bottom_thickness_vs_width_and_spacing: K_BOTTOM_THICKNESS_VS_WIDTH_AND_SPACING $@11 '{' spacings widths values '}'  */
#line 1064 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->conductor.set_tvf_bt_vws(v_lut);
    v_lut.clear();
    v_is_lut_working = 0;
  }
#line 3106 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 225: /* $@12: %empty  */
#line 1073 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    v_lut.set_names("WIDTHS", "DELTAPD", "VALUES");
    v_is_lut_working = 1;
  }
#line 3115 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 226: /* bottom_thickness_vs_width_and_deltapd: K_BOTTOM_THICKNESS_VS_WIDTH_AND_DELTAPD $@12 '{' deltapd widths values '}'  */
#line 1082 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->conductor.set_tvf_bt_vwd(v_lut);
    v_lut.clear();
    v_is_lut_working = 0;
  }
#line 3125 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 227: /* deltapd: K_DELTAPD '{' float_list '}'  */
#line 1091 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    v_lut.set_data_list<float>("DELTAPD", v_float_list);
    v_float_list.clear();
  }
#line 3134 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 229: /* keyword_list: keyword_list KEYWORD  */
#line 1106 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {

  }
#line 3142 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 231: /* linked_to: K_LINKED_TO '=' layer_name  */
#line 1114 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {

  }
#line 3150 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 233: /* raised_diffusion_thickness: K_RAISED_DIFFUSION_THICKNESS '=' NUMBER  */
#line 1125 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {

  }
#line 3158 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 234: /* raised_diffusion_to_gate_smin: K_RAISED_DIFFUSION_TO_GATE_SMIN '=' NUMBER  */
#line 1132 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {

  }
#line 3166 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 266: /* vias: vias via  */
#line 1231 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    CALLBACK(itfCallbacks->via_cb, itfCallBackType::kViaCbType, &itfData->via);
    itfData->via.clear();
  }
#line 3175 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 268: /* $@13: %empty  */
#line 1240 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->via.set_via_name(v_layer_name);
  }
#line 3183 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 279: /* from: K_FROM '=' layer_name  */
#line 1265 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->via.set_from(v_layer_name);
  }
#line 3191 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 280: /* to: K_TO '=' layer_name  */
#line 1272 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->via.set_to(v_layer_name);
  }
#line 3199 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 281: /* crt_property: crt1  */
#line 1279 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->via.set_crt1(v_crt1);
  }
#line 3207 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 282: /* crt_property: crt2  */
#line 1282 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
              { itfData->via.set_crt2(v_crt2); }
#line 3213 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 284: /* crt_property: t0  */
#line 1284 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
              { itfData->via.set_t0(v_t0); }
#line 3219 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 286: /* area_crt1_crt2_list: area_crt1_crt2_list '(' NUMBER ',' NUMBER ',' NUMBER ')'  */
#line 1295 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->via.add_area_crt1_ct2((yyvsp[-5].dval), (yyvsp[-3].dval), (yyvsp[-1].dval));
  }
#line 3227 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 288: /* rho_property: rho  */
#line 1302 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
              { itfData->via.set_rho(v_rho); }
#line 3233 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 292: /* rpv: K_RPV '=' NUMBER  */
#line 1310 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->via.set_rpv((yyvsp[0].dval));
  }
#line 3241 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 293: /* area: K_AREA '=' NUMBER  */
#line 1317 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->via.set_area((yyvsp[0].dval));
  }
#line 3249 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 295: /* area_rpv_list: area_rpv_list '(' NUMBER ',' NUMBER ')'  */
#line 1330 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  { itfData->via.add_area_rpv((yyvsp[-3].dval), (yyvsp[-1].dval)); }
#line 3255 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 298: /* etch_property: etch_vs_width_and_spacing  */
#line 1337 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->via.set_etch_vws(v_etch_effect_type, v_lut);
    ITF_FREE(v_etch_effect_type);
    v_lut.clear();
    v_is_lut_working = 0;
  }
#line 3266 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 300: /* etch_property: K_CAPACITIVE_ONLY_ETCH '=' NUMBER  */
#line 1345 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  { itfData->via.set_capacitive_only_etch((yyvsp[0].dval)); }
#line 3272 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 301: /* $@14: %empty  */
#line 1350 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    v_lut.set_names("GATE_TO_CONTACT_SPACINGS", "CONTACT_TO_CONTACT_SPACINGS", "VALUES");
    v_is_lut_working = 1;
  }
#line 3281 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 302: /* etch_vs_contact_and_gate_spacings: K_ETCH_VS_CONTACT_AND_GATE_SPACINGS $@14 K_CAPACITIVE_ONLY '{' etch_vs_contact_and_gate_spacings_property '}'  */
#line 1357 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    v_is_lut_working = 0;
  }
#line 3289 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 303: /* etch_vs_contact_and_gate_spacings_property: table  */
#line 1364 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->via.get_etch_cg().add_table("", v_lut);
    v_lut.clear();
  }
#line 3298 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 304: /* etch_vs_contact_and_gate_spacings_property: number_of_tables name_tables  */
#line 1369 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->via.get_etch_cg().set_number_of_tables(v_number_of_tables);
    v_lut.clear();
  }
#line 3307 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 306: /* name_tables: name_tables table_name '{' table '}'  */
#line 1386 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->via.get_etch_cg().add_table(v_table_name, v_lut);
    v_lut.clear();

    v_lut.set_names("GATE_TO_CONTACT_SPACINGS", "CONTACT_TO_CONTACT_SPACINGS", "VALUES");
  }
#line 3318 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 308: /* table_name: KEYWORD  */
#line 1396 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
          { ITF_STR_CPY(v_table_name, (yyvsp[0].string)); }
#line 3324 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 309: /* $@15: %empty  */
#line 1401 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    v_etch_wlv_lut.set_names("WIDTHS", "LENGTHS", "VALUES");
  }
#line 3332 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 310: /* $@16: %empty  */
#line 1406 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
    {
      v_etch_wlv_lut.set_data_list<float>("LENGTHS", v_float_list);
      v_float_list.clear();
    }
#line 3341 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 311: /* $@17: %empty  */
#line 1411 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
    {
      v_etch_wlv_lut.set_data_list<float>("WIDTHS", v_float_list);
      v_float_list.clear();
    }
#line 3350 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 312: /* $@18: %empty  */
#line 1416 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
    {
      v_etch_wlv_lut.set_data_list<std::pair<float, float>>("VALUES", v_float_pair_list);
      v_float_pair_list.clear();
    }
#line 3359 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 313: /* etch_vs_width_and_length: K_ETCH_VS_WIDTH_AND_LENGTH $@15 etch_width_length_effect_type '{' K_LENGTHS '{' float_list '}' $@16 K_WIDTHS '{' float_list '}' $@17 K_VALUES '{' float_pair_list '}' $@18 '}'  */
#line 1421 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->via.set_etch_vwl(v_etch_effect_type, v_etch_wlv_lut);
    ITF_FREE(v_etch_effect_type);
    v_etch_wlv_lut.clear();
  }
#line 3369 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 314: /* etch_width_length_effect_type: K_RESISTIVE_ONLY  */
#line 1429 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
                    { ITF_STR_CPY(v_etch_effect_type, "RESISTIVE_ONLY"); }
#line 3375 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 315: /* etch_width_length_effect_type: K_CAPACITIVE_ONLY  */
#line 1430 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
                    { ITF_STR_CPY(v_etch_effect_type, "CAPACITIVE_ONLY"); }
#line 3381 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 316: /* etch_width_length_effect_type: %empty  */
#line 1432 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  { ITF_FREE(v_etch_effect_type); }
#line 3387 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 322: /* variation_param: variation_param_name '=' '{' variation_param_table '}'  */
#line 1459 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    CALLBACK(itfCallbacks->variation_cb, itfCallBackType::kVariationCbType, &itfData->variation_param);
    itfData->variation_param.clear();
  }
#line 3396 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 323: /* variation_param_name: KEYWORD  */
#line 1467 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  {
    itfData->variation_param.param_name = (yyvsp[0].string);
  }
#line 3404 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 326: /* variation_param_table_term: '(' layer_name ',' variation_param_type ',' NUMBER ')'  */
#line 1480 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
  { 
    v_vpt.layer = v_layer_name;
    v_vpt.coeff = (yyvsp[-1].dval);
    itfData->variation_param.add_term(v_vpt);
    v_vpt.clear();
  }
#line 3415 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 327: /* variation_param_type: K_THICKNESS  */
#line 1489 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
              { v_vpt.type = "THICKNESS"; }
#line 3421 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 328: /* variation_param_type: K_WIDTH  */
#line 1490 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
              { v_vpt.type = "WIDTH";     }
#line 3427 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 329: /* variation_param_type: K_RHO  */
#line 1491 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
              { v_vpt.type = "RHO";       }
#line 3433 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 330: /* variation_param_type: K_ER  */
#line 1492 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
              { v_vpt.type = "ER";        }
#line 3439 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 331: /* variation_param_type: K_RPV  */
#line 1493 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
              { v_vpt.type = "RPV";       }
#line 3445 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;

  case 332: /* variation_param_type: KEYWORD  */
#line 1494 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"
              { v_vpt.type = (yyvsp[0].string);          }
#line 3451 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"
    break;


#line 3455 "/home/lxq/AiEDA/iEDA.ai/build-aes13/src/operation/iRCX/source/parser/itf/generated/itf_parser.cpp"

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
  *++yylsp = yyloc;

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
  yytoken = yychar == ITF_EMPTY ? YYSYMBOL_YYEMPTY : YYTRANSLATE (yychar);
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
      yyerror (&yylloc, YY_("syntax error"));
    }

  yyerror_range[1] = yylloc;
  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
         error, discard it.  */

      if (yychar <= ITF_EOF)
        {
          /* Return failure if at end of input.  */
          if (yychar == ITF_EOF)
            YYABORT;
        }
      else
        {
          yydestruct ("Error: discarding",
                      yytoken, &yylval, &yylloc);
          yychar = ITF_EMPTY;
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

      yyerror_range[1] = *yylsp;
      yydestruct ("Error: popping",
                  YY_ACCESSING_SYMBOL (yystate), yyvsp, yylsp);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END

  yyerror_range[2] = yylloc;
  ++yylsp;
  YYLLOC_DEFAULT (*yylsp, yyerror_range, 2);

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
  yyerror (&yylloc, YY_("memory exhausted"));
  yyresult = 2;
  goto yyreturnlab;


/*----------------------------------------------------------.
| yyreturnlab -- parsing is finished, clean up and return.  |
`----------------------------------------------------------*/
yyreturnlab:
  if (yychar != ITF_EMPTY)
    {
      /* Make sure we have latest lookahead translation.  See comments at
         user semantic actions for why this is necessary.  */
      yytoken = YYTRANSLATE (yychar);
      yydestruct ("Cleanup: discarding lookahead",
                  yytoken, &yylval, &yylloc);
    }
  /* Do not reclaim the symbols of the rule whose action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
                  YY_ACCESSING_SYMBOL (+*yyssp), yyvsp, yylsp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif

  return yyresult;
}

#line 1497 "/home/lxq/AiEDA/iEDA.ai/src/operation/iRCX/source/parser/itf/itf_parser.yy"


} // namespace itf

void itf_error(ITF_LTYPE* yylloc_param, const char* s) {
  std::cout << "error: " << s << ", "
            << "at line " << yylloc_param->last_line << ", "
            << "col " << yylloc_param->last_column << std::endl;
}
