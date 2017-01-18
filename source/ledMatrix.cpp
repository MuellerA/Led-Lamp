////////////////////////////////////////////////////////////////////////////////
// ledMatrix.cpp
// (c) Andreas Müller
//     see LICENSE.md
////////////////////////////////////////////////////////////////////////////////

#include "ledMatrix.h"

////////////////////////////////////////////////////////////////////////////////
// LedMatrix
////////////////////////////////////////////////////////////////////////////////

void LedMatrix::CoordToIdx(unsigned char x, unsigned char y, unsigned char &idx)
{
#if defined(MATRIX_2x2X8x8)
  idx =
    ((x & 0x07) << 0) |
    ((y & 0x07) << 3) |
    ((x & 0x08) << 3) |
    ((y & 0x08) << 4) ;
#elif defined(MATRIX_8x8)
  idx =
    (x << 0) |
    (y << 3) ;
#elif defined(MATRIX_2X8x8)
  idx =
    ((x & 0x07) << 0) |
    ((y & 0x07) << 3) |
    ((x & 0x08) << 3) ;    
#else
  #error "undefined matrix layout"
#endif
}

////////////////////////////////////////////////////////////////////////////////

void LedMatrix::IdxToCoord(unsigned char idx, unsigned char &x, unsigned char &y)
{
#if defined(MATRIX_2x2X8x8)
  x =
    ((idx >> 0) & 0x07) |
    ((idx >> 3) & 0x08) ;
  y =
    ((idx >> 3) & 0x07) |
    ((idx >> 4) & 0x08) ;
#elif defined(MATRIX_8x8)
  x =
    ((idx >> 0) & 0x07) ;
  y =
    ((idx >> 3) & 0x07) ;
#elif defined(MATRIX_2X8x8)
  x =
    ((idx >> 0) & 0x07) |
    ((idx >> 3) & 0x08) ;
  y =
    ((idx >> 3) & 0x07) ;
#else
  #error "undefined matrix layout"
#endif
}

////////////////////////////////////////////////////////////////////////////////

void LedMatrix::Clear()
{
  for (unsigned short i = 0 ; i < kSize ; ++i)
    SendDataRGB(0, 0, 0) ;
}

////////////////////////////////////////////////////////////////////////////////

void LedMatrix::Blink(unsigned char col, unsigned char mode)
{
  Rgb black ;
  black.Clr() ;
  
  Rgb rgbCol ;
  switch (col)
  {
  case 0: rgbCol.Set(0xff, 0x00, 0x00) ; break ; // red
  case 1: rgbCol.Set(0x00, 0xff, 0x00) ; break ; // green
  case 2: rgbCol.Set(0x00, 0x00, 0xff) ; break ; // blue
  }
  for (unsigned short idx = 0 ; idx < LedMatrix::kSize ; ++idx)
  {
    Rgb *rgb = &black ;
    unsigned char x, y ;
    LedMatrix::IdxToCoord(idx, x, y) ;

    switch (mode)
    {
    case 0: if (x == 0)                 rgb = &rgbCol ; break ; // left
    case 1: if (x == LedMatrix::kX - 1) rgb = &rgbCol ; break ; // right
    case 2: if (y == 0)                 rgb = &rgbCol ; break ; // top
    case 3: if (y == LedMatrix::kY - 1) rgb = &rgbCol ; break ; // bottom
    case 4: if ((x == 0) || (x == LedMatrix::kX -1) ||
		(y == 0) || (y == LedMatrix::kY -1)) rgb = &rgbCol ; break ; // square
    }
    rgb->Send() ;
  }
}

////////////////////////////////////////////////////////////////////////////////
// LedMatrix::Rnd
////////////////////////////////////////////////////////////////////////////////

extern "C" unsigned char Rnd() ;
unsigned char LedMatrix::Rnd(unsigned char max)
{
  while (true)
  {
    unsigned char rnd = ::Rnd() ;
    
    if      (max <= 0x01) rnd &= 0x01 ;
    else if (max <= 0x03) rnd &= 0x03 ;
    else if (max <= 0x07) rnd &= 0x07 ;
    else if (max <= 0x0f) rnd &= 0x0f ;
    else if (max <= 0x1f) rnd &= 0x1f ;
    else if (max <= 0x3f) rnd &= 0x3f ;
    else if (max <= 0x7f) rnd &= 0x7f ;
      
    if (rnd <= max)
      return rnd ;
  }
}

////////////////////////////////////////////////////////////////////////////////

void Rgb::Clr(unsigned char init)
{
  _r = _g = _b = init << 6 ;
}

void Rgb::Set(unsigned char r, unsigned char g, unsigned char b)
{
  _r = r << 6 ; _g = g << 6 ; _b = b << 6 ;
}

void Rgb::Add(const Rgb &add)
{
  _r += add._r ; _g += add._g ; _b += add._b ;
}

void Rgb::Sub(const Rgb &sub)
{
  _r -= sub._r ; _g -= sub._g ; _b -= sub._b ;
}

void Rgb::Max(unsigned char m)
{
  unsigned short cc = 0 ;
  cc += _r ;
  cc += _g ;
  cc += _b ;

  unsigned short mm = (unsigned short)m << 7 ;
  while (cc > mm)
  {
    _r >>= 1 ;
    _g >>= 1 ;
    _b >>= 1 ;
    cc >>= 1 ;
  }
}

void Rgb::DivX()
{
  _r /= LedMatrix::kX ; _g /= LedMatrix::kX ; _b /= LedMatrix::kX ;
}

void Rgb::RShift(unsigned char s)
{
  _r >>= s ; _g >>= s ; _b >>= s ;
}

////////////////////////////////////////////////////////////////////////////////

void Rgb::Rnd(unsigned char max)
{
  short *c1, *c2, *c3 ;
  unsigned char order = LedMatrix::Rnd(5) ;
  switch (order)
  {
  default: c1 = &_r ; c2 = &_g ; c3 = &_b ; break ;
  case 1:  c1 = &_r ; c2 = &_b ; c3 = &_g ; break ;
  case 2:  c1 = &_g ; c2 = &_r ; c3 = &_b ; break ;
  case 3:  c1 = &_g ; c2 = &_b ; c3 = &_r ; break ;
  case 4:  c1 = &_b ; c2 = &_r ; c3 = &_g ; break ;
  case 5:  c1 = &_b ; c2 = &_g ; c3 = &_r ; break ;
  }
  
  *c1 = LedMatrix::Rnd(max) << 6 ;
  max -= *c1 >> 6 ;
  *c2 = LedMatrix::Rnd(max) << 6 ;
  max -= *c2 >> 6 ;
  *c3 = LedMatrix::Rnd(max) << 6 ;
}

////////////////////////////////////////////////////////////////////////////////

void Rgb::Send() const
{
  SendDataRGB((unsigned char)(_r >> 6),
	      (unsigned char)(_g >> 6),
	      (unsigned char)(_b >> 6)) ;
}

////////////////////////////////////////////////////////////////////////////////
// EOF
////////////////////////////////////////////////////////////////////////////////
