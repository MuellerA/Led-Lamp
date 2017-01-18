////////////////////////////////////////////////////////////////////////////////
// rain.cpp
// (c) Andreas Müller
//     see LICENSE.md
////////////////////////////////////////////////////////////////////////////////

#include "ledMatrix.h"

////////////////////////////////////////////////////////////////////////////////

class Rain
{
public:
  static const int NDROPS = 8 ;

  Rain() ;

  void Update() ;
  void Display() ;
  void Config(unsigned char type, unsigned char value) ;

private:
  struct Drop
  {
    unsigned char _x ;
    unsigned char _y ;
    Rgb _rgb ;
  } ;

  Drop _drops[NDROPS] ;
  unsigned char _brightness ;
  unsigned char _activeDrops ;
} ;

////////////////////////////////////////////////////////////////////////////////

Rain::Rain() : _brightness(0x7f), _activeDrops(0)
{
  for (unsigned char iDrop = 0 ; iDrop < NDROPS ; ++iDrop)
  {
    Drop &drop = _drops[iDrop] ;
    drop._x = drop._y = 0xff ;
    drop._rgb.Clr() ;
  }
}

void Rain::Update()
{
  bool init = false ;
  for (unsigned char iDrop = 0 ; iDrop < NDROPS ; ++iDrop)
  {
    Drop &drop = _drops[iDrop] ;

    if (drop._y == 0xff)
    {
      if (!init)
      {
	if ((_activeDrops < 2) || (LedMatrix::Rnd() < 20))
        {
	tryNextX:
	  drop._x = LedMatrix::Rnd(LedMatrix::kX-1) ;
	  for (unsigned char jDrop = 0 ; jDrop < NDROPS ; ++jDrop)
	  {
	    if ((iDrop != jDrop) &&
		(drop._x == _drops[jDrop]._x))
	      goto tryNextX ;
	  }
	  drop._y = 0 ;
	  drop._rgb.Rnd(_brightness) ;
	  init = true ;
	  _activeDrops += 1 ;
	}
      }
    }
    else if (drop._y < LedMatrix::kY+1)
    {
      drop._y += 1 ;
    }
    else
    {
      drop._x = drop._y = 0xff ;
      _activeDrops -= 1 ;
    }
  }
}

void Rain::Display()
{
  Rgb black ;
  black.Clr() ;

  for (unsigned short idx = 0 ; idx < LedMatrix::kSize ; ++idx)
  {
    Rgb *rgb = &black ;
    unsigned char x, y ;
    LedMatrix::IdxToCoord(idx, x, y) ;

    for (unsigned char iDrop = 0 ; iDrop < NDROPS ; ++iDrop)
    {
      Drop &drop = _drops[iDrop] ;
      if ((drop._x == x) &&
	  ((drop._y == y) || (drop._y == y+1)))
      {
	rgb = &drop._rgb ;
      }
    }
    rgb->Send() ;
  }
}

void Rain::Config(unsigned char type, unsigned char value)
{
  switch (type)
  {
  case LedMatrix::ConfigBrightness:
    _brightness = value ;
    break ;

  case LedMatrix::ConfigForceRedraw:
    break ;
  }
}

////////////////////////////////////////////////////////////////////////////////
// EOF
////////////////////////////////////////////////////////////////////////////////
