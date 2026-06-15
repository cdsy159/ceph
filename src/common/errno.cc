#include "common/errno.h"

#include <string.h>

#include <sstream>

#include "include/compat.h"

#include "acconfig.h"

std::string
cpp_strerror(int err)
{
  char buf[128];
  char* errmsg;

  if (err < 0)
    err = -err;
  std::ostringstream oss;

  errmsg = ceph_strerror_r(err, buf, sizeof(buf));

  oss << "(" << err << ") " << errmsg;

  return oss.str();
}
