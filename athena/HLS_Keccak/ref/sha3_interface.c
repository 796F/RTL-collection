/* *
 * @file       sha3_interface.c
 * @brief      HLS-based SHA-3 interface in C
 * @project    ARC-2015 HLS SHA-3
 * @author     Ekawat (ice) Homsirikamol
 * @version    1.0
 * @copyright  Copyright (c) 2014 Cryptographic Engineering Research Group
 *             ECE Department, George Mason University Fairfax, VA, U.S.A.
 *             All rights Reserved.
 * @license    This project is released under the GNU Public License.
 *             The license and distribution terms for this file may be
 *             found in the file LICENSE in this distribution or at
 *             http://www.gnu.org/licenses/gpl-3.0.txt
 * @note       This is publicly available encryption source code that falls
 *             under the License Exception TSU (Technology and software-
 *             —unrestricted)
 */

 #include <stdio.h>
#include <math.h>
#include "ap_cint.h"

#define STATE_RESET       0
#define STATE_WAIT_HEADR1 1
#define STATE_WAIT_HEADR2 2
#define STATE_WAIT_DATA   3

#define OSTATE_RESET       6
#define OSTATE_WAIT_HASH   4
#define OSTATE_WAIT_OUTPUT 5


#define LOG2(n) (log(n) / log( 2 ))
#define HASHSIZE 256
#define IOSIZE    64
#define LOG2_IOSIZE ((int) LOG2(IOSIZE))
#define BLOCKSIZE 1088
#define WORDS_IN_BLOCK  BLOCKSIZE/IOSIZE

#if BLOCKSIZE == 512
  typedef uint512 blockwidth;
#else if BLOCKSIZE == 1088
  typedef uint1088 blockwidth;
#endif

#if IOSIZE == 64
  typedef uint64 iowidth;
#define ONES 0xFFFFFFFFFFFFFFFF
#endif

#if HASHSIZE == 256
  typedef uint256 hashwidth;
#else
  typedef uint512 hashwidth;
#endif

void fifo_interface_din(iowidth *din, blockwidth *msg, uint32 *size, uint1 *last)
{
#pragma HLS INTERFACE ap_ctrl_none port=return
#pragma HLS INTERFACE ap_fifo port=din
#pragma HLS INTERFACE ap_fifo port=msg
#pragma HLS INTERFACE ap_none port=size
#pragma HLS INTERFACE ap_none port=last

  static int       count      = 0;
  static blockwidth msg_reg    = 0;
  static uint8     state      = STATE_RESET;
  static uint32    sgt_words  = 0;
  static uint32    sgt_size   = 0;
  static uint1     is_eom     = 0;

  uint64 tmp;

  if (state == STATE_RESET)
    state = STATE_WAIT_HEADR1;
  else if (state == STATE_WAIT_HEADR1)
    {
      tmp        = *din;
      sgt_words  = (tmp >> LOG2_IOSIZE) & 0x7FFFFFFF;
      is_eom     = (tmp >> (IOSIZE-1)) & 0x1;
      if (is_eom == 1)
        state      = STATE_WAIT_HEADR2;
      else
      {
        state      = STATE_WAIT_DATA;
        sgt_size   = (unsigned int)  (tmp & 0x7FFFFFFF);
      }
    }
  else if (state == STATE_WAIT_HEADR2)
    {
      tmp        = *din;
      sgt_size   = (unsigned int)  (tmp & 0x7FFFFFFF);
      state      = STATE_WAIT_DATA;
    }
  else if (state == STATE_WAIT_DATA)
    {
      if (sgt_words > 0)
        {
          tmp     = *din;
          msg_reg = (msg_reg << IOSIZE) ^ tmp;
          sgt_words = sgt_words - 1;
        }
      if (count == WORDS_IN_BLOCK-1)
        {
          count = 0;
          *msg  = msg_reg;
          if (sgt_size >= BLOCKSIZE)
            {
              *size = BLOCKSIZE;
              sgt_size = sgt_size - BLOCKSIZE;
            }
          else
            {
              *size = sgt_size;
              sgt_size = 0;
            }
          if (sgt_words == 0)
            {
              if (is_eom == 1)
                *last = 1;
              else
                *last = 0;
              state = STATE_RESET;
            }
          else
            *last = 0;
        }
      else
        {
          count = count + 1;
        }
    }
}

void fifo_interface_dout(hashwidth *hash, iowidth *dout)
{
#pragma HLS INTERFACE ap_ctrl_none port=return
#pragma HLS INTERFACE ap_fifo port=hash
#pragma HLS INTERFACE ap_fifo port=dout

  static int       count     = 0;
  static hashwidth hash_reg  = 0;
  static uint8   state     = OSTATE_RESET;

  uint1 extra_block;
  uint4 tempOpcode;
  uint4 tempStype;
  uint4 outStype;
  uint32 bypass_data;

  if (state == OSTATE_RESET)
    state = OSTATE_WAIT_HASH;
  else if (state == OSTATE_WAIT_HASH)
    {
      hash_reg = *hash;
      state    = OSTATE_WAIT_OUTPUT;
    }
  else if (state == OSTATE_WAIT_OUTPUT)
    {
      *dout    = (hash_reg >> (HASHSIZE - IOSIZE)) & ONES;
      hash_reg = hash_reg << IOSIZE;
      if (count == (HASHSIZE/IOSIZE)-1)
        {
          count = 0;
          state = OSTATE_WAIT_HASH;
        }
      else
        count++;
    }
}
