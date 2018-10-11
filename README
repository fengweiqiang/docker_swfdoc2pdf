## Convert swf doc to pdf

### Intruction

Use swftools (http://swftools.org) to extact jpeg files in swf and chrome-headless-render-pdf (https://www.npmjs.com/package/chrome-headless-render-pdf) to
 convert jpegs to pdf file.

### Uages

1. Use docker compose to startup swftools & html2pdf containers.

```
docker-compose up
```

2. Put swf file in tmp folder.

3. Call swf2img API run in swftools container. (Use test.swf for example.)

```
curl http://127.0.0.1:4010/test.swf
```
and return

```
0fx7mnji/output.html
```

4. Call html2pdf API run in html2pdf container.

```
curl http://127.0.0.1:4012/0fx7mnji/output.html
> /0fx7mnji/output.pdf
```
5. Download generated pdf file.

```
wget http://127.0.0.1:4011/0fx7mnji/output.pdf
```

And also all the generated files are placed in tmp/ folder.





