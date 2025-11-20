package diffiehellman

import (
	"crypto/rand"
	"math/big"
)

// Diffie-Hellman-Merkle key exchange
// Private keys should be generated randomly.

func PrivateKey(p *big.Int) *big.Int {
	one := big.NewInt(1)
	minimal := big.NewInt(2)            // output >1 hence minimal is 2
	maximal := new(big.Int).Sub(p, one) // output < p hence p-1

	// We want a range of size (p - 2), because a random value in [0 .. p-3]
	// can be shifted by +2 to fall into the valid private key range [2 .. p-1].
	//
	// Calculation:
	//   max = p - 1
	//   min = 2
	//   rangeSize = (max - min + 1)
	//             = (p - 1) - 2 + 1
	//             = p - 2
	//
	// Notes:
	//   rand.Int(reader, n) produces values in the range [0 .. n-1],
	//   so using a range size of (p - 2) correctly yields [0 .. p-3],
	//   which becomes [2 .. p-1] after adding 2.
	rangeSize := new(big.Int).Sub(maximal, minimal)
	rangeSize.Add(rangeSize, one)

	r, _ := rand.Int(rand.Reader, rangeSize)
	r.Add(r, minimal)
	return r
}

func PublicKey(private, p *big.Int, g int64) *big.Int {
	bigG := big.NewInt(g)
	res := new(big.Int).Exp(bigG, private, p)
	return res
}

func NewPair(p *big.Int, g int64) (*big.Int, *big.Int) {
	privateKey := PrivateKey(p)
	publicKey := PublicKey(privateKey, p, g)
	return privateKey, publicKey
}

func SecretKey(private1, public2, p *big.Int) *big.Int {
	res := new(big.Int).Exp(public2, private1, p)
	return res
}
