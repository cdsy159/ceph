#pragma once

#include <dirent.h>
#include <errno.h>
#include <math.h>
#include <stdlib.h>
#include <time.h>

#include <climits>
#include <fstream>
#include <iostream>
#include <locale>
#include <memory>
#include <sstream>
#include <stdexcept>

#include "common/debug.h"

#include <boost/program_options/parsers.hpp>
#include <boost/program_options/variables_map.hpp>

#include "cls/cas/cls_cas_client.h"
#include "cls/cas/cls_cas_internal.h"
#include "common/CDC.h"
#include "common/Cond.h"
#include "common/Formatter.h"
#include "common/Preforker.h"
#include "common/ceph_argparse.h"
#include "common/ceph_crypto.h"
#include "common/config.h"
#include "common/errno.h"
#include "common/obj_bencher.h"
#include "global/global_init.h"
#include "global/signal_handler.h"
#include "include/rados/buffer.h"
#include "include/rados/librados.hpp"
#include "include/rados/rados_types.hpp"
#include "include/stringify.h"
#include "include/types.h"
#include "tools/RadosDump.h"

#include "acconfig.h"

#define dout_context g_ceph_context
#define dout_subsys ceph_subsys_ceph_dedup

namespace po = boost::program_options;
using namespace librados;

constexpr unsigned default_op_size = 1 << 26;

std::string get_opts_pool_name(const po::variables_map& opts);
std::string get_opts_chunk_algo(const po::variables_map& opts);
std::string get_opts_fp_algo(const po::variables_map& opts);
std::string get_opts_op_name(const po::variables_map& opts);
std::string get_opts_chunk_pool(const po::variables_map& opts);
std::string get_opts_object_name(const po::variables_map& opts);
int get_opts_max_thread(const po::variables_map& opts);
int get_opts_report_period(const po::variables_map& opts);
std::string make_pool_str(std::string pool, std::string var, std::string val);
std::string make_pool_str(std::string pool, std::string var, int val);
