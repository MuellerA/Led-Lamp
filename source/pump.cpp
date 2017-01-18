////////////////////////////////////////////////////////////////////////////////
// pump.cpp
// (c) Andreas Müller
//     see LICENSE.md
////////////////////////////////////////////////////////////////////////////////

#include "ledMatrix.h"

////////////////////////////////////////////////////////////////////////////////

class Pump
{
public:
  Pump(unsigned char mode) ;

  void Update() ;
  void Display() ;
  void Config(unsigned char type, unsigned char value) ;

private:
  unsigned char _mode ;
  Rgb &_curRgb ;
  Rgb _deltaRgb ;
  Rgb _rgb[LedMatrix::kX/2] ;
  unsigned char _brightness ;
  unsigned char _state ;
} ;

static_assert(sizeof(Pump) < (RAMSIZE - 0x28), "not enough RAM") ;

////////////////////////////////////////////////////////////////////////////////

Pump::Pump(unsigned char mode) : _mode(mode), _curRgb(_rgb[LedMatrix::kX/2 - 1]), _brightness(0x7f), _state(0)
{
  for (Rgb *iRgb = _rgb, *eRgb = _rgb + LedMatrix::kX/2 ; iRgb < eRgb ; ++iRgb)
    iRgb->Clr(0x10) ;
  _deltaRgb.Rnd(_brightness) ;
  _deltaRgb.Sub(_curRgb) ;
  _deltaRgb.DivX() ;
}

void Pump::Update()
{
  if (_state == 0)
  {
    _deltaRgb.Rnd(_brightness) ;
    _deltaRgb.Sub(_curRgb) ;
    _deltaRgb.DivX() ;
  }

  if (_state < LedMatrix::kX)
  {
    for (unsigned char x2 = 0 ; x2 < LedMatrix::kX/2 - 1 ; ++x2)
      _rgb[x2] = _rgb[x2+1] ;

    _curRgb.Add(_deltaRgb) ;
  }
  else if (_state < LedMatrix::kX * 2)
  {
    for (unsigned char x2 = 0 ; x2 < LedMatrix::kX/2 - 1 ; ++x2)
      _rgb[x2] = _rgb[x2+1] ;
  }

  if (++_state == LedMatrix::kX * 3)
    _state = 0 ;
}

void Pump::Display()
{
  for (unsigned short idx = 0 ; idx < LedMatrix::kSize ; ++idx)
  {
    switch (_mode)
    {
    case 1:
      {
	unsigned char  x, y ;
	LedMatrix::IdxToCoord(idx, x, y) ;
	if (x >= LedMatrix::kX/2)
	  x = LedMatrix::kX-1 - x ;
	if (y >= LedMatrix::kY/2)
	  y = LedMatrix::kY-1 - y ; 
	if (y < x)
	  x = y ;
	_rgb[x].Send() ;
      }
      break ;
    default:
      {
	_curRgb.Send() ;
      }
      break ;
    }
  }
}

void Pump::Config(unsigned char type, unsigned char value)
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
