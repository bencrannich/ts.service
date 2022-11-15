#include <cstdio>
#include <cstdarg>

namespace ts
{
	class diag
	{
	public:
		static const int INFO = 0;

		static void log(int level, const char *message);
		static void logf(int level, const char *format, ...);
		static void vlogf(int level, const char *format, va_list ap);
		static void info(const char *message);
	};
}

void
ts::diag::info(const char *string)
{
	std::fputs(string, stdout);
}

int
main(int argc, char **argv)
{
	(void) argc;
	(void) argv;

	ts::diag::info("Connected to Terminal Server\n");
	
	return 0;
}