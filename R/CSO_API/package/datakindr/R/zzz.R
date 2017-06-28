.onLoad <- function(libname, pkgname) {
  op <- options()
  op.datakindr <- list(
    datakindr.install.args = "",
    datakindr.name = "Cormac Nolan",
    datakindr.desc.author = '"Cormac Nolan <cormacnolan85@gmail.com> [aut, cre]"',
    datakindr.desc.license = "GPL-3",
    datakindr.desc.suggests = NULL,
    datakindr.desc = list()
  )
  toset <- !(names(op.datakindr) %in% names(op))
  if(any(toset)) options(op.datakindr[toset])

  invisible()
}
