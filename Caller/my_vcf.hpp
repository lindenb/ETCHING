//--------------------------------------------------------------------
// Copyright 2020. Bioinformatic and Genomics Lab.
// Hanyang University, Seoul, Korea
// Coded by Jang-il Sohn (sohnjangil@gmail.com)
//--------------------------------------------------------------------


#ifndef MY_VCF
#define MY_VCF

#include <string>
#include <vector>
#include <map>
#include <unordered_map>
#include <set>
#include <iostream>
#include <fstream>
#include <chrono>
#include <assert.h>
#include <iterator>
#include <time.h>
#include <cmath>

#include <api/BamAlignment.h>
#include <api/BamReader.h>
#include <api/BamWriter.h>

#include "types.hpp"
#include "functions.hpp"



class VCF{
private:
  void input_features(std::string feature_str);
  void input_features_2(std::string feature_str);
  std::string cut_str(std::string & input, std::string key);
  
public:
  VCF(){};
  VCF(std::string);
  ~VCF(){};

  std::string parse(std::string);
  void parse_etching(std::string);

  Feature parse_feature(std::string feature);

  std::string chr1;
  int64_t pos1;
  std::string sv_id;
  std::string sv_id_add;
  std::string ref;
  std::string alt;
  int64_t qual;
  std::string filter;
  std::string info;
  
  std::string feature_str;
  std::string feature_str1;
  std::string feature_str2;

  Feature feature;
  Feature feature1;
  Feature feature2;

   // for comparing with other tools
  std::vector < int64_t > tool_comp;
  int64_t tool_count;
  
  std::string chr2;
  int64_t pos2;

  std::string strand;


  std::string mate_id; // for BND
  std::string svtype; // INS, DEL, DUP, INV, BND
  int64_t svlen; // SV length
  std::string data_type;

  // features of first mate
  int64_t cr; // number of Clipped Reads supporing the variation
  int64_t sr; // number of Split Reads supporing the variation
  int64_t pe; // number of PE reads supporing the variation
  int64_t mq;
  double depdif;
  int64_t nxa;
  int64_t tcb; // Number of total clipped base
  double entropy;

  // features of second mate
  int64_t cr2; // number of Clipped Reads supporing the variation
  int64_t sr2; // number of Split Reads supporing the variation
  int64_t pe2; // number of PE reads supporing the variation
  int64_t mq2;
  double depdif2;
  int64_t nxa2;
  int64_t tcb2; // Number of total clipped base
  double entropy2;

  // global features
  double purity;
  double seqdep;

  int64_t read_number;


  void modify_svtype_info();
  void make_info();

  std::string to_string();
  std::string to_string_short();

  void resize_tool_comp(int64_t Size);

};

VCF return_mate(VCF input);


///////////////////////////////////////////////////////////
using VCF_MAP=std::map < Position , std::vector < VCF > >;


class VCF_CLASS{
private:
  std::vector < std::pair < std::string , std::size_t > > genome_info;
  void build_id_ref_map(const std::string infile);
  char GetNucl(const std::string & , const std::size_t &);

public:
  VCF_CLASS();
  VCF_CLASS(const std::string input_file);
  ~VCF_CLASS();

  std::string etching_version;
  
  // Main container
  VCF_MAP vcf_map;
  
  std::string vcf_file;
  std::string reference;

  std::string metainfo;
  std::string header;

  double seqdep;
  double purity;
  std::string seqtype;

  std::string bam_file;
  std::string single_file;
  std::string pair_file;
  int64_t insert_size;
  int64_t read_length;

  
  BamTools::RefVector refvector;
  std::unordered_map < std::string , int64_t > id_ref_map;
  std::unordered_map < int64_t , std::string > ref_id_map;

  std::map < std::string , std::string > genome;

  void read_vcf_file(const std::string infile);

  void get_genome();
  void get_genome(std::string);
  void make_header();
  void make_header_short();
  void clear();

  VCF_MAP::iterator begin();
  VCF_MAP::iterator end();

  void write();
  void fwrite(std::string);
  void write_short();
  void fwrite_short(std::string);
  std::size_t size();

  // void insert ( std::string chr1, int64_t pos1, std::string chr2, int64_t pos2, std::string sv_id, std::string mate_id, std::string strand, std::string svtype);
  void insert ( std::string chr1, int64_t pos1, std::string chr2, int64_t pos2, std::string sv_id, std::string mate_id, std::string strand, int64_t sr_val, std::string svtype);


  void insert ( VCF vcf );

  // void find_mate();
  // void clean_unmate();


  void calc_features(const std::string input_bam, const int64_t read_length, const int64_t insert_size, const int64_t confi_window);
  void calc_features_general(const std::string input_bam, const int64_t read_length, const int64_t insert_size, const int64_t confi_window);

  //`void fill_mate_feature();
  
  void add_features_in_id();

  VCF_MAP::iterator find(Position Pos);
  bool check_vcf( std::string chr1, int64_t pos1, std::string chr2, int64_t pos2, std::string BND_type );
  std::map<Position,double> calc_link_entropy (const std::string pair_file);

  std::vector < VCF > & operator [](Position Pos);

  void make_info();
};
  
double return_depdif(Position Pos, std::vector < double > & dep_vec, int64_t Size, double read_length);

void copy_info ( VCF_CLASS & source , VCF_CLASS & target );

VCF_CLASS typing_SV(VCF_CLASS & source);
VCF_CLASS typing_SV_general(VCF_CLASS & source);
VCF_CLASS typing_SV_manta ( VCF_CLASS & input );

void calc_features(const std::string input_bam, std::vector < VCF_CLASS > & container_vec,
		   const int64_t read_length, const int64_t insert_size, const int64_t confi_window) ;

#endif

