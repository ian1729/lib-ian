file(GLOB headers "${DIR}/*.hpp")

set(banned_c_compat
    "<cstdio>" "<cstdlib>" "<cstring>" "<cmath>" "<cassert>"
    "<cctype>" "<ctime>" "<cerrno>" "<csignal>" "<csetjmp>"
    "<clocale>" "<cwchar>" "<cwctype>" "<cstddef>" "<cstdint>" "<climits>")

foreach(header IN LISTS headers)
    file(READ "${header}" content)

    if(content MATCHES "#include <[a-z_]+\\.h>")
        message(FATAL_ERROR "C header in public API: ${header}\n"
            "Move it to detail/ or replace with a C++ standard header.")
    endif()

    foreach(banned IN LISTS banned_c_compat)
        if(content MATCHES "#include ${banned}")
            message(FATAL_ERROR "C compatibility header ${banned} in public API: ${header}\n"
                "Move it to detail/.")
        endif()
    endforeach()
endforeach()
