------------------------------------------------------------------------------
-- Project    : Red Zombie
------------------------------------------------------------------------------
-- File       :  video_ram_pkg.vhd
-- Author     :  fpgakuechle
-- Company    :  hobbyist
-- Created    :  2012-12
-- Last update: 2013-03-16
-- Licence    : GNU General Public License (http://www.gnu.de/documents/gpl.de.html)
------------------------------------------------------------------------------
-- Description: 
-- used by video_ram.vhd
-- Video memory
-- types and powerUp screen
------------------------------------------------------------------------------
--Last Change: Init Screen with borders, using hexnumbers in index

library ieee;
use ieee.std_logic_1164.all;

package video_ram_pkg is
  SUBTYPE T_VRAM_INDEX IS integer RANGE  0 TO 2**10 - 1;
  SUBTYPE T_WORD       IS integer RANGE 2**8  - 1 DOWNTO 0;
  TYPE    T_VRAM       IS ARRAY (T_VRAM_INDEX'low TO T_VRAM_INDEX'high) OF T_WORD;

--POWERUP screen as initvalues for videoram
  --character tests: letters and digits
  constant C_VRAM_ARRAY_INIT : T_VRAM := (
    --first line
    16#000# => 16#0BC#, 16#001# to 16#01E# => 16#B6#, 16#01F# => 16#BD#,
    --2nd line: col index
    16#020# => 16#B4#,
    16#021# => 16#31#, 16#022# => 16#32#, 16#023# => 16#33#, 16#024# => 16#34#,
    16#025# => 16#35#, 16#026# => 16#36#, 16#027# => 16#37#, 16#028# => 16#38#,
    16#029# => 16#39#, 16#02A# => 16#30#, 16#02B# => 16#31#, 16#02C# => 16#32#,
    16#02D# => 16#33#, 16#02E# => 16#34#, 16#02F# => 16#35#, 

    16#030# => 16#36#,
    16#031# => 16#37#, 16#032# => 16#38#, 16#033# => 16#39#, 16#034# => 16#30#,
    16#035# => 16#31#, 16#036# => 16#32#, 16#037# => 16#33#, 16#038# => 16#34#,
    16#039# => 16#35#, 16#03A# => 16#36#, 16#03B# => 16#37#, 16#03C# => 16#38#,
    16#03D# => 16#39#, 16#03E# => 16#30#,  
    16#03F# => 16#B5#,

    --0x00-x0F chars
    74 => 16#00#, 75 => 16#01#, 76 => 16#02#, 77 => 16#03#, 78 => 16#04#, 79 => 16#05#, 80 => 16#06#, 81 => 16#07#,
    84 => 16#08#, 85 => 16#09#, 86 => 16#0A#, 87 => 16#0B#, 88 => 16#0C#, 89 => 16#0D#, 90 => 16#0E#, 91 => 16#0F#,
    --0x10-x1F chars
    106 => 16#10#, 107 => 16#11#, 108 => 16#12#, 109 => 16#13#, 110 => 16#14#, 111 => 16#15#, 112 => 16#16#, 113 => 16#17#,
    116 => 16#18#, 117 => 16#19#, 118 => 16#1A#, 119 => 16#1B#, 120 => 16#1C#, 121 => 16#1D#, 122 => 16#1E#, 123 => 16#1F#,
    --0x20-x2F chars
    138 => 16#20#, 139 => 16#21#, 140 => 16#22#, 141 => 16#23#, 142 => 16#24#, 143 => 16#25#, 144 => 16#26#, 145 => 16#27#,
    148 => 16#28#, 149 => 16#29#, 150 => 16#2A#, 151 => 16#2B#, 152 => 16#2C#, 153 => 16#2D#, 154 => 16#2E#, 155 => 16#2F#,
    --0x30-x3F digits and relation
    170 => 16#30#, 171 => 16#31#, 172 => 16#32#, 173 => 16#33#, 174 => 16#34#, 175 => 16#35#, 176 => 16#36#, 177 => 16#37#,
    180 => 16#38#, 181 => 16#39#, 182 => 16#3A#, 183 => 16#3B#, 184 => 16#3C#, 185 => 16#3D#, 186 => 16#3E#, 187 => 16#3F#,
    --0x40-x4F capital letters
    202 => 16#40#, 203 => 16#41#, 204 => 16#42#, 205 => 16#43#, 206 => 16#44#, 207 => 16#45#, 208 => 16#46#, 209 => 16#47#,
    212 => 16#48#, 213 => 16#49#, 214 => 16#4A#, 215 => 16#4B#, 216 => 16#4C#, 217 => 16#4D#, 218 => 16#4E#, 219 => 16#4F#,
    --0x50-x5F capital letter
    234 => 16#50#, 235 => 16#51#, 236 => 16#52#, 237 => 16#53#, 238 => 16#54#, 239 => 16#55#, 240 => 16#56#, 241 => 16#57#,
    244 => 16#58#, 245 => 16#59#, 246 => 16#5A#, 247 => 16#5B#, 248 => 16#5C#, 249 => 16#5D#, 250 => 16#5E#, 251 => 16#5F#,
    --0x60-x6F small letter
    266 => 16#60#, 267 => 16#61#, 268 => 16#62#, 269 => 16#63#, 270 => 16#64#, 271 => 16#65#, 272 => 16#66#, 273 => 16#67#,
    276 => 16#68#, 277 => 16#69#, 278 => 16#6A#, 279 => 16#6B#, 280 => 16#6C#, 281 => 16#6D#, 282 => 16#6E#, 283 => 16#6F#,
    --0x70-x7F small letter
    298 => 16#70#, 299 => 16#71#, 300 => 16#72#, 301 => 16#73#, 302 => 16#74#, 303 => 16#75#, 304 => 16#76#, 305 => 16#77#,
    308 => 16#78#, 309 => 16#79#, 310 => 16#7A#, 311 => 16#7B#, 312 => 16#7C#, 313 => 16#7D#, 314 => 16#7E#, 315 => 16#7F#,

    --0x80-x8F
    362 => 16#80#, 363 => 16#81#, 364 => 16#82#, 365 => 16#83#, 366 => 16#84#, 367 => 16#85#, 368 => 16#86#, 369 => 16#87#,
    372 => 16#88#, 373 => 16#89#, 374 => 16#8A#, 375 => 16#8B#, 376 => 16#8C#, 377 => 16#8D#, 378 => 16#8E#, 379 => 16#8F#,
    --0x90-x9F
    394 => 16#90#, 395 => 16#91#, 396 => 16#92#, 397 => 16#93#, 398 => 16#94#, 399 => 16#95#, 400 => 16#96#, 401 => 16#97#,
    404 => 16#98#, 405 => 16#99#, 406 => 16#9A#, 407 => 16#9B#, 408 => 16#9C#, 409 => 16#9D#, 410 => 16#9E#, 411 => 16#9F#,
    --0xA0-xAF
    426 => 16#A0#, 427 => 16#A1#, 428 => 16#A2#, 429 => 16#A3#, 430 => 16#A4#, 431 => 16#A5#, 432 => 16#A6#, 433 => 16#A7#,
    436 => 16#A8#, 437 => 16#A9#, 438 => 16#AA#, 439 => 16#AB#, 440 => 16#AC#, 441 => 16#AD#, 442 => 16#AE#, 443 => 16#AF#,
    --0xB0-xBF
    458 => 16#B0#, 459 => 16#B1#, 460 => 16#B2#, 461 => 16#B3#, 462 => 16#B4#, 463 => 16#B5#, 464 => 16#B6#, 465 => 16#B7#,
    468 => 16#B8#, 469 => 16#B9#, 470 => 16#BA#, 471 => 16#BB#, 472 => 16#BC#, 473 => 16#BD#, 474 => 16#BE#, 475 => 16#BF#,
    --0xC0-xCF
    490 => 16#C0#, 491 => 16#C1#, 492 => 16#C2#, 493 => 16#C3#, 494 => 16#C4#, 495 => 16#C5#, 496 => 16#C6#, 497 => 16#C7#,
    500 => 16#C8#, 501 => 16#C9#, 502 => 16#CA#, 503 => 16#CB#, 504 => 16#CC#, 505 => 16#CD#, 506 => 16#CE#, 507 => 16#CF#,
    --0xD0-xDF
    522 => 16#D0#, 523 => 16#D1#, 524 => 16#D2#, 525 => 16#D3#, 526 => 16#D4#, 527 => 16#D5#, 528 => 16#D6#, 529 => 16#D7#,
    532 => 16#D8#, 533 => 16#D9#, 534 => 16#DA#, 535 => 16#DB#, 536 => 16#DC#, 537 => 16#DD#, 538 => 16#DE#, 539 => 16#DF#,
    --0xE0-xEF
    554 => 16#E0#, 555 => 16#E1#, 556 => 16#E2#, 557 => 16#E3#, 558 => 16#E4#, 559 => 16#E5#, 560 => 16#E6#, 561 => 16#E7#,
    564 => 16#E8#, 565 => 16#E9#, 566 => 16#EA#, 567 => 16#EB#, 568 => 16#EC#, 569 => 16#ED#, 570 => 16#EE#, 571 => 16#EF#,
    --0xF0-xFF
    586 => 16#F0#, 587 => 16#F1#, 588 => 16#F2#, 589 => 16#F3#, 590 => 16#F4#, 591 => 16#F5#, 592 => 16#F6#, 593 => 16#F7#,
    596 => 16#F8#, 597 => 16#F9#, 598 => 16#FA#, 599 => 16#FB#, 600 => 16#FC#, 601 => 16#FD#, 602 => 16#FE#, 603 => 16#FF#,

    --left border
    16#040# => 16#B4#, 16#041# => 16#32#,
    16#060# => 16#B4#, 16#061# => 16#33#,
    16#080# => 16#B4#, 16#081# => 16#34#,
    16#0A0# => 16#B4#, 16#0A1# => 16#35#,
    16#0C0# => 16#B4#, 16#0C1# => 16#36#,
    16#0E0# => 16#B4#, 16#0E1# => 16#37#,
    16#100# => 16#B4#, 16#101# => 16#38#,
    16#120# => 16#B4#, 16#121# => 16#39#,
    16#140# => 16#B4#, 16#141# => 16#30#,
    16#160# => 16#B4#, 16#161# => 16#31#,
    16#180# => 16#B4#, 16#181# => 16#32#,
    16#1A0# => 16#B4#, 16#1A1# => 16#33#,
    16#1C0# => 16#B4#, 16#1C1# => 16#34#,
    16#1E0# => 16#B4#, 16#1E1# => 16#35#,
    16#200# => 16#B4#, 16#201# => 16#36#,
    16#220# => 16#B4#, 16#221# => 16#37#,
    16#240# => 16#B4#, 16#241# => 16#38#,
    16#260# => 16#B4#, 16#261# => 16#39#,
    16#280# => 16#B4#, 16#281# => 16#30#,
    16#2A0# => 16#B4#, 16#2A1# => 16#31#,
    16#2C0# => 16#B4#, 16#2C1# => 16#32#,
    16#2E0# => 16#B4#, 16#2E1# => 16#33#,
    16#300# => 16#B4#, 16#301# => 16#34#,
    16#320# => 16#B4#, 16#321# => 16#35#,
    16#340# => 16#B4#, 16#341# => 16#36#,
    16#360# => 16#B4#, 16#361# => 16#37#,
    16#380# => 16#B4#, 16#381# => 16#38#,
    16#3A0# => 16#B4#, 16#3A1# => 16#39#,
    16#3C0# => 16#B4#, 16#3C1# => 16#30#,
    -- right border
    16#05F# => 16#B5#, 16#05E# => 16#32#,
    16#07F# => 16#B5#, 16#07E# => 16#33#,
    16#09F# => 16#B5#, 16#09E# => 16#34#,
    16#0BF# => 16#B5#, 16#0BE# => 16#35#,
    16#0DF# => 16#B5#, 16#0DE# => 16#36#,
    16#0FF# => 16#B5#, 16#0FE# => 16#37#,
    16#11F# => 16#B5#, 16#11E# => 16#38#,
    16#13F# => 16#B5#, 16#13E# => 16#39#,
    16#15F# => 16#B5#, 16#15E# => 16#30#,
    16#17F# => 16#B5#, 16#17E# => 16#31#,
    16#19F# => 16#B5#, 16#19E# => 16#32#,
    16#1BF# => 16#B5#, 16#1BE# => 16#33#,
    16#1DF# => 16#B5#, 16#1DE# => 16#34#,
    16#1FF# => 16#B5#, 16#1FE# => 16#35#,
    16#21F# => 16#B5#, 16#21E# => 16#36#,
    16#23F# => 16#B5#, 16#23E# => 16#37#,
    16#25F# => 16#B5#, 16#25E# => 16#38#,
    16#27F# => 16#B5#, 16#27E# => 16#39#,
    16#29F# => 16#B5#, 16#29E# => 16#30#,
    16#2BF# => 16#B5#, 16#2BE# => 16#31#,
    16#2DF# => 16#B5#, 16#2DE# => 16#32#,
    16#2FF# => 16#B5#, 16#2FE# => 16#33#,
    16#31F# => 16#B5#, 16#31E# => 16#34#,
    16#33F# => 16#B5#, 16#33E# => 16#35#,
    16#35F# => 16#B5#, 16#35E# => 16#36#,
    16#37F# => 16#B5#, 16#37E# => 16#37#,
    16#39F# => 16#B5#, 16#39E# => 16#38#,
    16#3BF# => 16#B5#, 16#3BE# => 16#39#,
    16#3DF# => 16#B5#, 16#3DE# => 16#30#,
    
    --last line
    16#3E0#  => 16#BB#, 16#3E1# to 16#3FE# => 16#B7#, 16#3FF# => 16#BA#,
    
    others => 16#20#);
  --only spaces -> blank screen
    constant C_VRAM_ARRAY_SPACES_INIT : T_VRAM := (others => 16#20#);
end package video_ram_pkg;

