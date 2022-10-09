all: static dynamic

static:
	gcc -c test.c test.h
	ar rcs libtest.a test.o
	mv libtest.a ../lib/

dynamic: 
	gcc -fPIC  test.c test.h -o ../lib/libtest.so -shared

clean:
	rm -f *.o ../lib/libtest.a ../lib/libtest.so
