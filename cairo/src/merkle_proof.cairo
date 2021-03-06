%builtins output pedersen range_check ecdsa bitwise

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.cairo_builtins import HashBuiltin

from sha256.sha256 import compute_sha256
from merkle import createMerkleTree, prepareMerkleTree, calculateHeight

from io import N_BYTES_BLOCK, N_BYTES_HASH, FELT_HASH_LEN, FELT_BLOCK_LEN, outputHash

###
#       This Program proofs the inclusion of an intermediary header
#       at position [X] in the given batch. To do so, we calculate the
#       Merkle root over all block headers again. The resulting root
#       will be compared to the original root that was calculated
#       while validating the blocks and is now stored in the contract.
###

func main{
        output_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, ecdsa_ptr : felt*,
        bitwise_ptr : BitwiseBuiltin*}():
    alloc_locals
    local blocksLen : felt
    local intermediaryIndex : felt
    let (blocks : felt**) = alloc()
    %{
        ids.blocksLen = len(program_input["Blocks"])
        ids.intermediaryIndex = program_input["blockToHash"]
        segments.write_arg(ids.blocks, program_input["Blocks"])
    %}
    let (height) = calculateHeight(blocksLen)
    let intermediaryHeader = [blocks + intermediaryIndex]

    # output the specified header -> TODO IMPROVEMENT: This could be compressed to lesser uint128's (If you change it here do it in the contract and validate.cairo too <3 )
    serialize_word([intermediaryHeader])
    serialize_word([intermediaryHeader + 1])
    serialize_word([intermediaryHeader + 2])
    serialize_word([intermediaryHeader + 3])
    serialize_word([intermediaryHeader + 4])
    serialize_word([intermediaryHeader + 5])
    serialize_word([intermediaryHeader + 6])
    serialize_word([intermediaryHeader + 7])
    serialize_word([intermediaryHeader + 8])
    serialize_word([intermediaryHeader + 9])
    serialize_word([intermediaryHeader + 10])
    serialize_word([intermediaryHeader + 11])
    serialize_word([intermediaryHeader + 12])
    serialize_word([intermediaryHeader + 13])
    serialize_word([intermediaryHeader + 14])
    serialize_word([intermediaryHeader + 15])
    serialize_word([intermediaryHeader + 16])
    serialize_word([intermediaryHeader + 17])
    serialize_word([intermediaryHeader + 18])
    serialize_word([intermediaryHeader + 19])

    # calculate the block hash and output it
    let (hash_first) = compute_sha256(
        input_len=FELT_BLOCK_LEN, input=intermediaryHeader, n_bytes=N_BYTES_BLOCK)
    let (hash_second) = compute_sha256(
        input_len=FELT_HASH_LEN, input=hash_first, n_bytes=N_BYTES_HASH)
    outputHash(hash_second)
    # calculate and output the merkle root of the batch
    let (leaves_ptr) = alloc()
    prepareMerkleTree(leaves_ptr, blocks, blocksLen, 0)
    let (merkleRoot) = createMerkleTree(leaves_ptr, 0, blocksLen, height)
    serialize_word(merkleRoot)

    return ()
end
