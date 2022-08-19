IMAGES = awgn.eps eyediagram.eps scatterplot.eps awgn.pdf eyediagram.pdf scatterplot.pdf awgn.png eyediagram.png scatterplot.png
IMAGES_EPS = awgn.eps eyediagram.eps scatterplot.eps
IMAGES_PDF = awgn.pdf eyediagram.pdf scatterplot.pdf
IMAGES_PNG = awgn.png eyediagram.png scatterplot.png
awgn.eps: commsimages.m
	$(OCTAVE) --path=$(CURDIR)/../inst -f -q -H --eval "commsimages ('awgn', 'eps');"
eyediagram.eps: commsimages.m
	$(OCTAVE) --path=$(CURDIR)/../inst -f -q -H --eval "commsimages ('eyediagram', 'eps');"
scatterplot.eps: commsimages.m
	$(OCTAVE) --path=$(CURDIR)/../inst -f -q -H --eval "commsimages ('scatterplot', 'eps');"
awgn.pdf: commsimages.m
	$(OCTAVE) --path=$(CURDIR)/../inst -f -q -H --eval "commsimages ('awgn', 'pdf');"
eyediagram.pdf: commsimages.m
	$(OCTAVE) --path=$(CURDIR)/../inst -f -q -H --eval "commsimages ('eyediagram', 'pdf');"
scatterplot.pdf: commsimages.m
	$(OCTAVE) --path=$(CURDIR)/../inst -f -q -H --eval "commsimages ('scatterplot', 'pdf');"
awgn.png: commsimages.m
	$(OCTAVE) --path=$(CURDIR)/../inst -f -q -H --eval "commsimages ('awgn', 'png');"
eyediagram.png: commsimages.m
	$(OCTAVE) --path=$(CURDIR)/../inst -f -q -H --eval "commsimages ('eyediagram', 'png');"
scatterplot.png: commsimages.m
	$(OCTAVE) --path=$(CURDIR)/../inst -f -q -H --eval "commsimages ('scatterplot', 'png');"
