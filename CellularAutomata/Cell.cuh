#pragma once
#include "CommonLib.cuh"

enum ColorChannel : sf::Uint8 {
	r, g, b, a
};

enum CellType : sf::Uint8 {
	None,
	Dead,
	Attacker,
	Passive,
	Plant,
	MAX
};

__device__ inline sf::Uint8 GetCellColor(CellType p, ColorChannel Channel)
{
	sf::Uint8 c[5][4] = { 
		{0,0,0,255}, //none
		{100,100,100,255}, //dead
		{255,100,0,255}, //attacker
		{100,0,255,255}, //passive
		{0, 255, 100, 255} //plant
	};
	return c[p][Channel];
}

#define ViewDistance 2

__device__ inline CellType GetNewCell(CellType Current, short* n) {
	switch (Current) {
	case None:
		if (n[Attacker] > 1) return Attacker;
		if (n[Passive] > 0 && n[Attacker] < 3) return Passive;
		//if (n[Dead] > 1 && n[None] + n[Dead] > 2) return Plant;
			break;
	case Dead:
		if (n[Passive] < 2 && n[None] > 1) return Plant;
		return None;
		if(n[Plant] > 0 || n[None] == 0) return None;
		break;
	case Attacker:
		if (n[Attacker] >= n[Passive] || (n[None] + n[Dead] < 2)) return Dead;
		break;
	case Passive:
		if (n[Attacker] >= n[Passive] || n[None] + n[Dead] < 1 || n[Plant] == 0) return Dead;
		break;
	case Plant:
		if (n[Passive] > 1 || n[None] + n[Dead] < 1) return Dead;
		break;
	}
	return Current;
}