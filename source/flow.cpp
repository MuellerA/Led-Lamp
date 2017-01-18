////////////////////////////////////////////////////////////////////////////////
// flow.cpp
// (c) Andreas Müller
//     see LICENSE.md
////////////////////////////////////////////////////////////////////////////////

#include "ledMatrix.h"

////////////////////////////////////////////////////////////////////////////////

class Flow
{
public:
  Flow(unsigned char mode) ;

  void Update() ;
  void Display() ;
  void Config(unsigned char type, unsigned char value) ;

private:
  unsigned char _mode ;
  Rgb &_curRgb ;
  Rgb _deltaRgb ;
  Rgb _rgb[LedMatrix::kX] ;
  unsigned char _brightness ;
  unsigned char _state ;
} ;

static_assert(sizeof(Flow) < (RAMSIZE - 0x28), "not enough RAM") ;

////////////////////////////////////////////////////////////////////////////////

Flow::Flow(unsigned char mode) : _mode(mode), _curRgb(_rgb[0]), _brightness(0x7f), _state(0)
{
  for (Rgb *iRgb = _rgb, *eRgb = _rgb + LedMatrix::kX ; iRgb < eRgb ; ++iRgb)
    iRgb->Clr(0x10) ;
  _deltaRgb.Rnd(_brightness) ;
  _deltaRgb.Sub(_curRgb) ;
  _deltaRgb.DivX() ;
}

void Flow::Update()
{
  if (_state == 0)
  {
    _deltaRgb.Rnd(_brightness) ;
    _deltaRgb.Sub(_curRgb) ;
    _deltaRgb.DivX() ;
  }

  if (_state < LedMatrix::kX)
  {
    for (unsigned char x2 = LedMatrix::kX - 1 ; x2 > 0 ; --x2)
      _rgb[x2] = _rgb[x2-1] ;
  
    _curRgb.Add(_deltaRgb) ;
  }
  else if (_state < LedMatrix::kX * 2)
  {
    for (unsigned char x2 = LedMatrix::kX - 1 ; x2 > 0 ; --x2)
      _rgb[x2] = _rgb[x2-1] ;
  }

  if (++_state == LedMatrix::kX * 3)
    _state = 0 ;
}

void Flow::Display()
{
  for (unsigned short idx = 0 ; idx < LedMatrix::kSize ; ++idx)
  {
    switch (_mode)
    {
    default:
      {
	unsigned char  x, y ;
	LedMatrix::IdxToCoord(idx, x, y) ;
	_rgb[x].Send() ;
      }
      break ;
    }
  }
}

void Flow::Config(unsigned char type, unsigned char value)
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
