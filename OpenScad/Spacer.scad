// Durchmesser (mm)
d =  5 ;
// Höhe (mm)
h = 32 ;
// Stärke (mm)
w =  1.2 ;

/* [Hidden] */
$fn = 64 ;


difference()
{
    cylinder(d=d+2*w, h) ;
    cylinder(d=d    , h) ;
}