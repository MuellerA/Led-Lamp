////////////////////////////////////////////////////////////////////////////////
// ball.cpp
// (c) Andreas Müller
//     see LICENSE.md
////////////////////////////////////////////////////////////////////////////////

#include "ball.h"

////////////////////////////////////////////////////////////////////////////////
// Ball
////////////////////////////////////////////////////////////////////////////////

Ball::Pos::Pos(const Ball &ball) : _p(LedMatrix::Rnd()), _dp(LedMatrix::Rnd(10)+5)
{
  if (_p >= 0xf0) _p = 0xef ;
  if (_p <  0x10) _p = 0x10 ;
}

void Ball::Pos::Update()
{
  if (_dp < 0)
  {
    if (_p < (unsigned char)-_dp)
      _dp = LedMatrix::Rnd(10)+5 ;
  }
  else
  {
    if (_p >= (unsigned char)-_dp)
      _dp = -LedMatrix::Rnd(10)-5 ;
  }
  _p += _dp ;
}

unsigned char Ball::Pos::operator()() const
{
  return _p ;
}

////////////////////////////////////////////////////////////////////////////////

Ball::Ball() : _x(*this), _y(*this), _brightness(0x7f), _colState(0), _maxColState(0)
{
  _curRgb.Rnd(_brightness) ;
}

void Ball::Update()
{
  _x.Update() ;
  _y.Update() ;

  if (_colState == 0)
  {
    _deltaRgb.Rnd(_brightness) ;
    _deltaRgb.Sub(_curRgb) ;
    _deltaRgb.DivX() ; // _colState
    _maxColState = 2 * LedMatrix::kX + LedMatrix::Rnd(LedMatrix::kX) ;
  }

  if (_colState < 2 * LedMatrix::kX)
  {
    if (_colState & 1)
      _curRgb.Add(_deltaRgb) ;
  }

  if (++_colState >= 2 * _maxColState)
    _colState = 0 ;
}

////////////////////////////////////////////////////////////////////////////////
// LedMatrixBall
////////////////////////////////////////////////////////////////////////////////

LedMatrixBall::LedMatrixBall()
{
}

void LedMatrixBall::Update()
{
  for (Ball *iBall = _balls, *eBall = _balls + kBalls ; iBall < eBall ; ++iBall)
  {
    iBall->Update() ;
  }
}

void LedMatrixBall::Display()
{
  Rgb black ;
  black.Clr() ;

  for (unsigned short idx = 0 ; idx < LedMatrix::kSize ; ++idx)
  {
    unsigned char x, y ;

    LedMatrix::IdxToCoord(idx, x, y) ;
    const Rgb *rgb = &black ;

    for (Ball *iBall = _balls, *eBall = _balls + kBalls ; iBall < eBall ; ++iBall)
    {
      unsigned char bx = iBall->X() >> LedMatrix::kShiftX ;
      unsigned char by = iBall->Y() >> LedMatrix::kShiftY ;

      char dx = bx - x ;
      char dy = by - y ;

      if (dx < 0) dx = -dx ;
      if (dy < 0) dy = -dy ;

      if ((dx+dy) <= 1)
	rgb = &iBall->CurRgb() ;
    }

    rgb->Send() ;
  }
}

void LedMatrixBall::Config(unsigned char cfg, unsigned char value)
{
  switch (cfg)
  {
  case LedMatrix::ConfigBrightness:
    for (Ball *iBall = _balls, *eBall = _balls + kBalls ; iBall < eBall ; ++iBall)
      iBall->Brightness(value) ;
    break ;

  case LedMatrix::ConfigForceRedraw:
    break ;
  }
}

////////////////////////////////////////////////////////////////////////////////
// EOF
////////////////////////////////////////////////////////////////////////////////
