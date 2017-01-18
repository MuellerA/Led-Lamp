////////////////////////////////////////////////////////////////////////////////
// constCol.h
// (c) Andreas Müller
//     see LICENSE.md
////////////////////////////////////////////////////////////////////////////////

#include "ledMatrix.h"

////////////////////////////////////////////////////////////////////////////////

class ConstCol
{
public:
  // make sure the r,g,b values do not exceed power supply current
  ConstCol(unsigned char r, unsigned char g, unsigned char b) ;
  void Update() ;
  void Display() ;
  void Config(unsigned char type, unsigned char value) ;

private:
  Rgb _rgb0 ;
  Rgb _rgb ;
  bool _update ;
} ;

static_assert(sizeof(ConstCol) < (RAMSIZE - 0x28), "not enough RAM") ;

////////////////////////////////////////////////////////////////////////////////

ConstCol::ConstCol(unsigned char r, unsigned char g, unsigned char b) : _update(true)
{
  _rgb0.Set(r, g, b) ;
  _rgb = _rgb0 ;
}

void ConstCol::Update()
{
}

void ConstCol::Display()
{
  if (_update)
  {
    for (unsigned short i = 0 ; i < LedMatrix::kSize ; ++i)
      _rgb.Send() ;
    _update = false ;
  }
}

void ConstCol::Config(unsigned char type, unsigned char value)
{
  switch (type)
  {
  case LedMatrix::ConfigBrightness:
    _rgb = _rgb0 ;
    _rgb.Max(value) ;
    _update = true ;
    break ;

  case LedMatrix::ConfigForceRedraw:
    _update = true ;
    break ;
  }
}

////////////////////////////////////////////////////////////////////////////////
// EOF
////////////////////////////////////////////////////////////////////////////////
