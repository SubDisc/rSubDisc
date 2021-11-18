
.onLoad <- function(libname, pkgname){
  jarlib = system.file("java", "subdisc-1.x.x.jar", package = pkgname)

  if (file.exists(jarlib)){
    rJava::.jinit(jarlib)
    packageStartupMessage("JVM initialized. Loaded jar: ", jarlib, "\n")
  } else {
    packageStartupMessage("JVM not initialized: Cannot load", jarlib, "\n")
  }
}

