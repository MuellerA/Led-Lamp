////////////////////////////////////////////////////////////////////////////////
// MultiCol.h
// (c) Andreas Müller
//     see LICENSE.md
////////////////////////////////////////////////////////////////////////////////

#include "ledMatrix.h"

////////////////////////////////////////////////////////////////////////////////

class MultiCol
{
public:
  MultiCol(unsigned char div) ;
  void Update() ;
  void Display() ;
  void Config(unsigned char type, unsigned char value) ;

private:
  unsigned char _brightness ;
  Rgb _rgb[16] ;
  unsigned char _state[16] ;
  unsigned char _col[LedMatrix::kSize] ;
} ;

////////////////////////////////////////////////////////////////////////////////

MultiCol::MultiCol(unsigned char div) : _brightness(0x7f)
{
  unsigned char shift ;
  
  if (!div)
  {
    shift = 3 ; /* /8 */
  }
  else
  {
    shift = 2 ; /* /4 */
  }

  for (unsigned char i = 0 ; i < 16 ; ++i)
  {
    _rgb[i].Rnd(_brightness) ;
    _state[i] = LedMatrix::Rnd(3 * LedMatrix::kX) ;
  }

  for (unsigned short idx = 0 ; idx < LedMatrix::kSize ; ++idx)
  {
    unsigned char x, y ;
    LedMatrix::IdxToCoord(idx, x, y) ;
    x >>= shift ;
    y >>= shift ;

    _col[idx] = y*4 + x ;
  }
}

void MultiCol::Update()
{
  for (unsigned char i = 0 ; i < 16 ; ++i)
    if (_state[i]-- == 0)
    {
      _rgb[i].Rnd(_brightness) ;
      _state[i] = LedMatrix::kX * 3 + LedMatrix::Rnd(LedMatrix::kX) ;
    }
}

void MultiCol::Display()
{
  for (unsigned short idx = 0 ; idx < LedMatrix::kSize ; ++idx)
  {
    _rgb[_col[idx]].Send() ;
  }
}

void MultiCol::Config(unsigned char type, unsigned char value)
{
  switch (type)
  {
  case LedMatrix::ConfigBrightness:
    _brightness = value ;
    for (unsigned char i = 0 ; i < 16 ; ++i)
      _rgb[i].Max(_brightness) ;
    break ;
  }
}

////////////////////////////////////////////////////////////////////////////////
// EOF
////////////////////////////////////////////////////////////////////////////////
