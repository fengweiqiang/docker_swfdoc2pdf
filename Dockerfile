FROM pink33n/html-to-pdf

ADD jpeg.patch /tmp/jpeg.patch

RUN apt-get update && apt-get install -y wget make g++ patch zlib1g-dev libgif-dev ruby

RUN cd /tmp && \
wget http://www.swftools.org/swftools-2013-04-09-1007.tar.gz && \
wget http://download.savannah.gnu.org/releases/freetype/freetype-2.4.0.tar.gz && \
wget http://www.ijg.org/files/jpegsrc.v9a.tar.gz

RUN cd /tmp && tar zxf freetype-2.4.0.tar.gz && \
tar zxf jpegsrc.v9a.tar.gz && \
tar zxf swftools-2013-04-09-1007.tar.gz

RUN cd /tmp/jpeg-9a && \
./configure && make && make install

RUN cd /tmp/freetype-2.4.0 && \
./configure && make && make install

RUN cd /tmp && patch -p0 < /tmp/jpeg.patch && \
cd swftools-2013-04-09-1007 && \
./configure && make && make install && \
ranlib /usr/local/lib/libjpeg.a && ldconfig /usr/local/lib

RUN cd /tmp && rm -rf swftools* && \
rm -rf jpeg* && rm -rf freetype*
