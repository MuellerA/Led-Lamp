OPENSCAD = /usr/bin/openscad-nightly
INKSCAPE = /usr/bin/inkscape
CP       = /bin/cp -a
RM       = /bin/rm -f

ALL:	TV/CJMCU-8x8.scad	\
	TV/CJMCU-8x8.stl	\
	TV/CJMCU-8x8-1.jpg	\
	TV/CJMCU-8x8-2.jpg	\
	TV/CJMCU-8x8-3.jpg	\
	TV/CJMCU-8x8-4.jpg	\
	TV/CJMCU-8x8-5.jpg	\
	TV/CJMCU-8x8-6.jpg	\
	TV/CJMCU-8x8-7.jpg

Clean:
	$(RM) TV/*

TV/%.scad: %.scad
	$(CP) $< $@

TV/CJMCU-8x8.stl:	CJMCU-8x8.scad
	$(OPENSCAD) -o $@ $<

TV/%.jpg: Images/%.jpg
	$(CP) $< $@
