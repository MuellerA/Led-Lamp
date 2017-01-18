////////////////////////////////////////////////////////////////////////////////
// ball.h
// (c) Andreas Müller
//     see LICENSE.md
////////////////////////////////////////////////////////////////////////////////

#pragma once

////////////////////////////////////////////////////////////////////////////////

#include "ledMatrix.h"

////////////////////////////////////////////////////////////////////////////////

class Ball
{
  class Pos
  {
  public:
    Pos(const Ball &ball) ;
    void Update() ;
    unsigned char operator()() const ;

  private:
    unsigned char _p ;
    char _dp ;
  } ;

public:
  Ball() ;
  void Update() ;
  unsigned char X() const  { return _x()  ; }
  unsigned char Y() const  { return _y()  ; }
  const Rgb& CurRgb() const { return _curRgb ; }
  void Brightness(unsigned char brightness) { _brightness = brightness ; }

private:
  Pos _x, _y ;
  unsigned char _brightness ;
  Rgb _curRgb ;
  Rgb _deltaRgb ;
  unsigned char _colState ;
  unsigned char _maxColState ;
} ;

////////////////////////////////////////////////////////////////////////////////

class LedMatrixBall
{
public:
  static const unsigned char kBalls = 6 ;

  LedMatrixBall() ;
  void Update() ;
  void Display() ;
  void Config(unsigned char cfg, unsigned char value) ;

private:
  Ball _balls[kBalls] ;
} ;

static_assert(sizeof(LedMatrixBall) < (RAMSIZE - 0x28), "not enough RAM") ;

////////////////////////////////////////////////////////////////////////////////
// EOF
////////////////////////////////////////////////////////////////////////////////
