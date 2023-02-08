#include "AESfunctions.h"
#include "AEStables.h"

void SubBytes(unsigned char* state) {
#pragma HLS inline off
	for (unsigned short i = 0; i < stt_lng; i++) {
#pragma HLS unroll
		state[i] = s_box[state[i]];
	}
}

void InvSubBytes(unsigned char* state) {
#pragma HLS inline off
	for (unsigned short i = 0; i < stt_lng; i++) {
#pragma HLS unroll
		state[i] = inverted_s_box[state[i]];
	}
}

void ShiftRows(unsigned char* state) {
#pragma HLS inline off
	unsigned char tmp_state[stt_lng];
	tmp_state[0] = state[0];
	tmp_state[1] = state[5];
	tmp_state[2] = state[10];
	tmp_state[3] = state[15];

	tmp_state[4] = state[4];
	tmp_state[5] = state[9];
	tmp_state[6] = state[14];
	tmp_state[7] = state[3];

	tmp_state[8] = state[8];
	tmp_state[9] = state[13];
	tmp_state[10] = state[2];
	tmp_state[11] = state[7];

	tmp_state[12] = state[12];
	tmp_state[13] = state[1];
	tmp_state[14] = state[6];
	tmp_state[15] = state[11];
	for (unsigned short i = 0; i < stt_lng; i++) {
		state[i] = tmp_state[i];
	}
}

void InvShiftRows(unsigned char* state) {
#pragma HLS inline off
	unsigned char tmp_state[stt_lng];
	tmp_state[0] = state[0];
	tmp_state[1] = state[13];
	tmp_state[2] = state[10];
	tmp_state[3] = state[7];

	tmp_state[4] = state[4];
	tmp_state[5] = state[1];
	tmp_state[6] = state[14];
	tmp_state[7] = state[11];

	tmp_state[8] = state[8];
	tmp_state[9] = state[5];
	tmp_state[10] = state[2];
	tmp_state[11] = state[15];

	tmp_state[12] = state[12];
	tmp_state[13] = state[9];
	tmp_state[14] = state[6];
	tmp_state[15] = state[3];
	for (unsigned short i = 0; i < stt_lng; i++) {
		state[i] = tmp_state[i];
	}
}

void MixColumns(unsigned char* state) {
#pragma HLS inline off
	unsigned char tmp_state[stt_lng];
	tmp_state[0] = mul02[state[0]] ^ mul03[state[1]] ^ state[2] ^ state[3];
	tmp_state[1] = state[0] ^ mul02[state[1]] ^ mul03[state[2]] ^ state[3];
	tmp_state[2] = state[0] ^ state[1] ^ mul02[state[2]] ^ mul03[state[3]];
	tmp_state[3] = mul03[state[0]] ^ state[1] ^ state[2] ^ mul02[state[3]];

	tmp_state[4] = mul02[state[4]] ^ mul03[state[5]] ^ state[6] ^ state[7];
	tmp_state[5] = state[4] ^ mul02[state[5]] ^ mul03[state[6]] ^ state[7];
	tmp_state[6] = state[4] ^ state[5] ^ mul02[state[6]] ^ mul03[state[7]];
	tmp_state[7] = mul03[state[4]] ^ state[5] ^ state[6] ^ mul02[state[7]];

	tmp_state[8] = mul02[state[8]] ^ mul03[state[9]] ^ state[10] ^ state[11];
	tmp_state[9] = state[8] ^ mul02[state[9]] ^ mul03[state[10]] ^ state[11];
	tmp_state[10] = state[8] ^ state[9] ^ mul02[state[10]] ^ mul03[state[11]];
	tmp_state[11] = mul03[state[8]] ^ state[9] ^ state[10] ^ mul02[state[11]];

	tmp_state[12] = mul02[state[12]] ^ mul03[state[13]] ^ state[14] ^ state[15];
	tmp_state[13] = state[12] ^ mul02[state[13]] ^ mul03[state[14]] ^ state[15];
	tmp_state[14] = state[12] ^ state[13] ^ mul02[state[14]] ^ mul03[state[15]];
	tmp_state[15] = mul03[state[12]] ^ state[13] ^ state[14] ^ mul02[state[15]];
	for (unsigned short i = 0; i < stt_lng; i++) {
		state[i] = tmp_state[i];
	}
}

void InvMixColumns(unsigned char* state) {
#pragma HLS inline off
	unsigned char tmp_state[stt_lng];
	tmp_state[0] = mul14[state[0]] ^ mul11[state[1]] ^ mul13[state[2]]
			^ mul09[state[3]];
	tmp_state[1] = mul09[state[0]] ^ mul14[state[1]] ^ mul11[state[2]]
			^ mul13[state[3]];
	tmp_state[2] = mul13[state[0]] ^ mul09[state[1]] ^ mul14[state[2]]
			^ mul11[state[3]];
	tmp_state[3] = mul11[state[0]] ^ mul13[state[1]] ^ mul09[state[2]]
			^ mul14[state[3]];

	tmp_state[4] = mul14[state[4]] ^ mul11[state[5]] ^ mul13[state[6]]
			^ mul09[state[7]];
	tmp_state[5] = mul09[state[4]] ^ mul14[state[5]] ^ mul11[state[6]]
			^ mul13[state[7]];
	tmp_state[6] = mul13[state[4]] ^ mul09[state[5]] ^ mul14[state[6]]
			^ mul11[state[7]];
	tmp_state[7] = mul11[state[4]] ^ mul13[state[5]] ^ mul09[state[6]]
			^ mul14[state[7]];

	tmp_state[8] = mul14[state[8]] ^ mul11[state[9]] ^ mul13[state[10]]
			^ mul09[state[11]];
	tmp_state[9] = mul09[state[8]] ^ mul14[state[9]] ^ mul11[state[10]]
			^ mul13[state[11]];
	tmp_state[10] = mul13[state[8]] ^ mul09[state[9]] ^ mul14[state[10]]
			^ mul11[state[11]];
	tmp_state[11] = mul11[state[8]] ^ mul13[state[9]] ^ mul09[state[10]]
			^ mul14[state[11]];

	tmp_state[12] = mul14[state[12]] ^ mul11[state[13]] ^ mul13[state[14]]
			^ mul09[state[15]];
	tmp_state[13] = mul09[state[12]] ^ mul14[state[13]] ^ mul11[state[14]]
			^ mul13[state[15]];
	tmp_state[14] = mul13[state[12]] ^ mul09[state[13]] ^ mul14[state[14]]
			^ mul11[state[15]];
	tmp_state[15] = mul11[state[12]] ^ mul13[state[13]] ^ mul09[state[14]]
			^ mul14[state[15]];
	for (unsigned short i = 0; i < stt_lng; i++) {
		state[i] = tmp_state[i];
	}
}

void AddRoundKey(unsigned char* state, unsigned char* roundKey) {
#pragma HLS inline off
	for (unsigned short i = 0; i < stt_lng; i++) {
#pragma HLS unroll
		state[i] ^= roundKey[i];
	}
}

// Cipher
void AES_Encrypt(unsigned char plaintext[stt_lng],
		unsigned char expandedKey[ExtdCipherKeyLenghth_max], unsigned short Nr,
		unsigned char ciphertext[stt_lng]) {


#pragma HLS inline region // will inline the functions unless inlining is off
#pragma HLS allocation instances=AddRoundKey limit=1 function // ensure only one instance of AddRoundKey
#pragma HLS array_map variable=s_box instance=cipher horizontal // group cipher tables together
#pragma HLS array_map variable=mul02 instance=cipher horizontal
#pragma HLS array_map variable=mul03 instance=cipher horizontal

// Copy plaintext into state
	unsigned char state[stt_lng];
	L_copy: for (unsigned short i = 0; i < stt_lng; i++) {
//#pragma HLS pipeline
		state[i] = plaintext[i];
	}

	// Whitening
	AddRoundKey(state, expandedKey + (stt_lng * 0)); // Round Key

	L_rounds: for (unsigned short i = 0; i < Nr; i++) {
//#pragma HLS pipeline
		SubBytes(state);
		ShiftRows(state);
		if (i != (Nr - 1)) {
			MixColumns(state);
		}
		AddRoundKey(state, expandedKey + (stt_lng * (i + 1))); // Round Key
	}

	// Copy state to ciphertext
	L_copy_o: for (unsigned short i = 0; i < stt_lng; i++) {
//#pragma HLS unroll
		ciphertext[i] = state[i];
	}
}

// Inverse Cipher
void AES_Decrypt(unsigned char ciphertext[stt_lng],
		unsigned char expandedKey[ExtdCipherKeyLenghth_max], unsigned short Nr,
		unsigned char plaintext[stt_lng]) {
#pragma HLS INTERFACE s_axilite port=ciphertext bundle=CRTLSic
#pragma HLS INTERFACE s_axilite port=expandedKey bundle=CRTLSic
#pragma HLS INTERFACE s_axilite port=Nr bundle=CRTLSic
#pragma HLS INTERFACE s_axilite port=plaintext bundle=CRTLSic
#pragma HLS INTERFACe s_axilite port=return bundle=CRTLSic

#pragma HLS inline region // will inline the functions unless inlining is off
#pragma HLS allocation instances=AddRoundKey limit=1 function // ensure only one instance of AddRoundKey
#pragma HLS array_map variable=inverted_s_box instance=inverse_cipher horizontal
#pragma HLS array_map variable=mul09 instance=inverse_cipher horizontal // group inverse cipher tables together
#pragma HLS array_map variable=mul11 instance=inverse_cipher horizontal
#pragma HLS array_map variable=mul13 instance=inverse_cipher horizontal
#pragma HLS array_map variable=mul14 instance=inverse_cipher horizontal

	// copy ciphertext into state
	unsigned char state[stt_lng];
	L_copy: for (unsigned short i = 0; i < stt_lng; i++) {
//#pragma HLS pipeline
		state[i] = ciphertext[i];
	}

	AddRoundKey(state, expandedKey + (stt_lng * Nr));  // Round Key

	L_rounds: for (unsigned short i = 0; i < Nr; i++) {
//#pragma HLS pipeline
		InvShiftRows(state);
		InvSubBytes(state);
		AddRoundKey(state, expandedKey + (stt_lng * (Nr - i - 1))); // Round Key
		if (i != (Nr - 1)) {
			InvMixColumns(state);
		}
	}

	// Copy state to plaintext
	L_copy_o: for (unsigned short i = 0; i < stt_lng; i++) {
//#pragma HLS unroll
		plaintext[i] = state[i];
	}
}

// AES Full
/*void AES_Full(bool mode_cipher, bool mode_inverse_cipher,
		unsigned char data_in[stt_lng],
		unsigned char expandedKey[ExtdCipherKeyLenghth_max], unsigned short Nr,
		unsigned char data_out[stt_lng]) {
#pragma HLS INTERFACE s_axilite port=mode_cipher bundle=CRTLS
#pragma HLS INTERFACE s_axilite port=mode_inverse_cipher bundle=CRTLS
#pragma HLS INTERFACE s_axilite port=data_in bundle=CRTLS
#pragma HLS INTERFACE s_axilite port=expandedKey bundle=CRTLS
#pragma HLS INTERFACE s_axilite port=Nr bundle=CRTLS
#pragma HLS INTERFACE s_axilite port=data_out bundle=CRTLS
#pragma HLS INTERFACe s_axilite port=return bundle=CRTLS

#pragma HLS inline region // will inline the functions unless inlining is off
	if (mode_cipher) {
		AES_Encrypt(data_in, expandedKey, Nr, data_out);
	}
	if (mode_inverse_cipher) {
		AES_Decrypt(data_in, expandedKey, Nr, data_out);
	}
}*/
