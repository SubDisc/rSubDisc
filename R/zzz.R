
SUBDISCLIB <- "subdisc-lib-2.1104.jar"

.onLoad <- function(libname, pkgname){
  jarlib = system.file("java", SUBDISCLIB, package = pkgname)

  if (file.exists(jarlib)){
    rJava::.jinit(jarlib)
    packageStartupMessage("JVM initialized. Loaded jar: ", jarlib, "\n")
  } else {
    packageStartupMessage("JVM not initialized: Cannot load", jarlib, "\n")
  }
}

