// Copyright (c) 2014-2022, The Zedcoin Project
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#include <iostream>

#include "string_tools.h"
#include "cryptonote_core/cryptonote_tx_utils.h"
#include "cryptonote_basic/account.h"
#include "cryptonote_basic/cryptonote_basic_impl.h"
#include "cryptonote_basic/cryptonote_format_utils.h"

int main()
{
  using namespace cryptonote;

  account_base miner;
  miner.generate();

  transaction tx;
  if (!construct_miner_tx(0, 0, 0, 0, 0, miner.get_keys().m_account_address, tx, blobdata(), 1, 1))
  {
    std::cerr << "Failed to construct genesis miner tx" << std::endl;
    return 1;
  }

  const blobdata tx_blob = tx_to_blob(tx);
  const std::string tx_hex = epee::string_tools::buff_to_hex_nodelimer(tx_blob);

  block genesis;
  generate_genesis_block(genesis, tx_hex, 0);
  const crypto::hash gen_hash = get_block_hash(genesis);

  std::cout << "GENESIS_TX=" << tx_hex << std::endl;
  std::cout << "GENESIS_NONCE=" << genesis.nonce << std::endl;
  std::cout << "GENESIS_HASH=" << epee::string_tools::pod_to_hex(gen_hash) << std::endl;
  std::cout << "MINER_ADDRESS=" << get_account_address_as_str(MAINNET, false, miner.get_keys().m_account_address) << std::endl;
  return 0;
}
