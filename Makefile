build:
	./dev-compose build

up: build
	./dev-compose up

start: build
	./dev-compose up -V --wait

down:
	./dev-compose down --remove-orphans

clean: down
	rm -rf dev/data	

fullclean: clean

rebuild: clean
	./dev-compose build 
	./dev-compose up -V --wait client

logs:
	./dev-compose logs -f
