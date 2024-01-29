//
//  sequential_generator.h
//  YCSB-cpp
//
//  Copyright (c) 2020 Youngjae Lee <ls4154.lee@gmail.com>.
//  Copyright (c) 2014 Jinglei Ren <jinglei@ren.systems>.
//

#ifndef YCSB_C_SEQUENTIAL_GENERATOR_H_
#define YCSB_C_SEQUENTIAL_GENERATOR_H_

#include "generator.h"

#include <atomic>
#include <random>

namespace ycsbc {

class SequentialGenerator : public Generator<uint64_t> {
 public:
  // Both min and max are inclusive
   SequentialGenerator(uint64_t min, uint64_t max) : start(min), end(max) { last_int_ = min; }

   uint64_t Next();
   uint64_t Last();

 private:
   uint64_t start;
   uint64_t end;
   uint64_t last_int_;
};

inline uint64_t SequentialGenerator::Next()
{
  return last_int_++;
}

inline uint64_t SequentialGenerator::Last()
{
  return last_int_;//TODO
}

} // ycsbc

#endif // YCSB_C_UNIFORM_GENERATOR_H_
