## Consensus variant calling workflow for human panel-based DNA sequencing.
## Input requirements:
## - Pair-end sequencing data in unmapped BAM (uBAM) format that comply with the following requirements:
## - - filenames all have the same suffix (we use ".unmapped.bam")
## - - files must pass validation by ValidateSamFile
## - - reads are provided in query-sorted order
## - - all reads must have an RG tag
##
## Output :
## - recalibrated bam and it's index and md5
## - GATK vcf
## - Annovar annotated vcfs and tabular file
## 
workflow Panel_BWA_GATK4_Annovar {
  # Batch File import
  File batchFile
  Array[Object] batchInfo = read_objects(batchFile)

  # Reference Data
  String ref_name
  File ref_fasta
  File ref_fasta_index
  File ref_dict
  # This is the .alt file from bwa-kit (https://github.com/lh3/bwa/tree/master/bwakit),
  # listing the reference contigs that are "alternative". Leave blank in JSON for legacy
  # references such as b37 and hg19.
  File? ref_alt
  File ref_amb
  File ref_ann
  File ref_bwt
  File ref_pac
  File ref_sa
  File dbSNP_vcf
  File dbSNP_vcf_index
  Array[File] known_indels_sites_VCFs
  Array[File] known_indels_sites_indices

  # Annovar specific variables
  File annovarDIR
  String annovar_protocols
  String annovar_operation

  # Gizmo Easybuild Modules
  String GATKModule
  String samtoolsModule
  String perlModule
  String bwaModule


scatter (job in batchInfo){
  String sampleName = job.sampleName
  File bamLocation = job.bamLocation
  File bedLocation = job.bedLocation

  # Get the basename, i.e. strip the filepath and the extension
  String bam_basename = basename(bamLocation, ".unmapped.bam")
  String base_file_name = sampleName + "." + ref_name


  # Prepare bed file and check sorting
  call SortBed {
    input:
      unsorted_bed = bedLocation,
      ref_dict = ref_dict,
      modules = GATKModule
  }
  # convert unmapped bam to fastq
  call SamToFastq {
    input:
      input_bam = bamLocation,
      base_file_name = base_file_name,
      modules = GATKModule
  }

#  Map reads to reference
  call BwaMem {
    input:
      input_fastq = SamToFastq.output_fastq,
      base_file_name = base_file_name,
      ref_fasta = ref_fasta,
      ref_fasta_index = ref_fasta_index,
      ref_dict = ref_dict,
      ref_alt = ref_alt,
      ref_amb = ref_amb,
      ref_ann = ref_ann,
      ref_bwt = ref_bwt,
      ref_pac = ref_pac,
      ref_sa = ref_sa,
      modules = bwaModule + " " + samtoolsModule
  }

  # Merge original uBAM and BWA-aligned BAM
  call MergeBamAlignment {
    input:
      unmapped_bam = bamLocation,
      aligned_bam = BwaMem.output_bam,
      base_file_name = base_file_name,
      ref_fasta = ref_fasta,
      ref_fasta_index = ref_fasta_index,
      ref_dict = ref_dict,
      modules = GATKModule
  }

  # Generate the recalibration model by interval
  call ApplyBaseRecalibrator {
    input:
      input_bam = MergeBamAlignment.output_bam,
      input_bam_index = MergeBamAlignment.output_bai,
      base_file_name = base_file_name,
      intervals = SortBed.intervals,
      dbSNP_vcf = dbSNP_vcf,
      dbSNP_vcf_index = dbSNP_vcf_index,
      known_indels_sites_VCFs = known_indels_sites_VCFs,
      known_indels_sites_indices = known_indels_sites_indices,
      ref_dict = ref_dict,
      ref_fasta = ref_fasta,
      ref_fasta_index = ref_fasta_index,
      modules = GATKModule + " " + samtoolsModule
    }

    # Generate haplotype caller vcf
    call HaplotypeCaller {
      input:
        input_bam = ApplyBaseRecalibrator.recalibrated_bam,
        input_bam_index = ApplyBaseRecalibrator.recalibrated_bai,
        intervals = SortBed.intervals,
        base_file_name = base_file_name,
        ref_dict = ref_dict,
        ref_fasta = ref_fasta,
        ref_fasta_index = ref_fasta_index,
        dbSNP_vcf = dbSNP_vcf,
        modules = GATKModule
    }

    # Annotate variants
    call annovar {
      input:
        input_vcf = HaplotypeCaller.output_vcf,
        ref_name = ref_name,
        base_file_name = base_file_name,
        annovar_operation = annovar_operation,
        annovar_protocols = annovar_protocols,
        annovarDIR = annovarDIR,
        modules = perlModule
    }

  # End scatter 
  }
  # Outputs that will be retained when execution is complete
  output {
    Array[File] analysis_ready_bam = ApplyBaseRecalibrator.recalibrated_bam 
    Array[File] analysis_ready_bai = ApplyBaseRecalibrator.recalibrated_bai
    Array[File] GATK_vcf = HaplotypeCaller.output_vcf
    Array[File] annotated_vcf = annovar.output_annotated_vcf
    Array[File] annotated_table = annovar.output_annotated_table
  }
# End workflow
}

# TASK DEFINITIONS

# Prepare bed file and check sorting
task SortBed {
  File unsorted_bed
  File ref_dict
  String modules
  command {
    set -eo pipefail

    echo "Sort bed file"
    sort -k1,1V -k2,2n -k3,3n ${unsorted_bed} > sorted.bed

    echo "Transform bed file to intervals list with Picard----------------------------------------"
    gatk --java-options "-Xms4g" \
      BedToIntervalList \
      -I=sorted.bed \
      -O=sorted.interval_list \
      -SD=${ref_dict}
  }
  runtime {
    modules: "${modules}"
  }
  output {
    File intervals = "sorted.interval_list"
    File sorted_bed = "sorted.bed"
  }
}
# Read unmapped BAM, convert to FASTQ
task SamToFastq {
  File input_bam
  String base_file_name
  String modules

  command {
    set -eo pipefail

    gatk --java-options "-Dsamjdk.compression_level=5 -Xms4g" \
      SamToFastq \
			--INPUT=${input_bam} \
			--FASTQ=${base_file_name}.fastq \
			--INTERLEAVE=true \
			--INCLUDE_NON_PF_READS=true 
  }
  runtime {
    modules: "${modules}"
    memory: "6GB"
    cpu: 2
    partition: "campus"
  }
  output {
    File output_fastq = "${base_file_name}.fastq"
  }
}

# align to genome
task BwaMem {
  File input_fastq
  String base_file_name
  File ref_fasta
  File ref_fasta_index
  File ref_dict
  File? ref_alt
  File ref_amb
  File ref_ann
  File ref_bwt
  File ref_pac
  File ref_sa
  String modules

  command {
    set -eo pipefail

    bwa mem \
      -p -v 3 -t 16 -M \
      ${ref_fasta} ${input_fastq} > ${base_file_name}.sam 
    samtools view -1bS -@ 15 -o ${base_file_name}.aligned.bam ${base_file_name}.sam
  }
  runtime {
    modules: "${modules}"
    memory: "33GB"
    cpu: 16
    partition: "largenode"
  }
  output {
    File output_bam = "${base_file_name}.aligned.bam"
  }
}


# Merge original input uBAM file with BWA-aligned BAM file
task MergeBamAlignment {
  File unmapped_bam
  File aligned_bam
  String base_file_name
  File ref_fasta
  File ref_fasta_index
  File ref_dict
  String modules
  command {
    set -eo pipefail

    gatk --java-options "-Dsamjdk.compression_level=5 -XX:-UseGCOverheadLimit -Xmx8g" \
      MergeBamAlignment \
      --VALIDATION_STRINGENCY SILENT \
      --EXPECTED_ORIENTATIONS FR \
      --ATTRIBUTES_TO_RETAIN X0 \
      --ALIGNED_BAM ${aligned_bam} \
      --UNMAPPED_BAM ${unmapped_bam} \
      --OUTPUT ${base_file_name}.merged.bam \
      --REFERENCE_SEQUENCE ${ref_fasta} \
      --PAIRED_RUN true \
      --SORT_ORDER coordinate \
      --IS_BISULFITE_SEQUENCE false \
      --ALIGNED_READS_ONLY false \
      --CLIP_ADAPTERS false \
      --MAX_RECORDS_IN_RAM 200000 \
      --ADD_MATE_CIGAR true \
      --MAX_INSERTIONS_OR_DELETIONS -1 \
      --PRIMARY_ALIGNMENT_STRATEGY MostDistant \
      --UNMAPPED_READ_STRATEGY COPY_TO_TAG \
      --ALIGNER_PROPER_PAIR_FLAGS true \
      --CREATE_INDEX true
  }
  runtime {
    modules: "${modules}"
    memory: "16GB"
    cpu: 4
  }
  output {
    File output_bam = "${base_file_name}.merged.bam"
    File output_bai = "${base_file_name}.merged.bai"
  }
}

 #Generate Base Quality Score Recalibration (BQSR) model and apply it
task ApplyBaseRecalibrator {
  File input_bam
  File intervals 
  File input_bam_index
  String base_file_name
  File dbSNP_vcf
  File dbSNP_vcf_index
  Array[File] known_indels_sites_VCFs
  Array[File] known_indels_sites_indices
  File ref_dict
  File ref_fasta
  File ref_fasta_index
  String modules
  command {
  set -eo pipefail

  samtools index ${input_bam}
  
  gatk --java-options "-Xms4g" \
      BaseRecalibrator \
      -R ${ref_fasta} \
      -I ${input_bam} \
      -O ${base_file_name}.recal_data.csv \
      --known-sites ${dbSNP_vcf} \
      --known-sites ${sep=" --known-sites " known_indels_sites_VCFs} \
      --intervals ${intervals} \
      --interval-padding 100 

  gatk --java-options "-Xms4g" \
      ApplyBQSR \
      -bqsr ${base_file_name}.recal_data.csv \
      -I ${input_bam} \
      -O ${base_file_name}.recal.bam \
      -R ${ref_fasta} \
      --intervals ${intervals} \
      --interval-padding 100 

  #finds the current sort order of this bam file
  samtools view -H ${base_file_name}.recal.bam | grep @SQ | sed 's/@SQ\tSN:\|LN://g' > ${base_file_name}.sortOrder.txt

  }
  runtime {
    modules: "${modules}"
    memory: "33GB"
    cpu: 6
    partition: "largenode"
  }
  output {
    File recalibrated_bam = "${base_file_name}.recal.bam"
    File recalibrated_bai = "${base_file_name}.recal.bai"
    File sortOrder = "${base_file_name}.sortOrder.txt"
  }
}


# HaplotypeCaller per-sample
task HaplotypeCaller {
  File input_bam
  File input_bam_index
  String base_file_name
  File intervals
  File ref_dict
  File ref_fasta
  File ref_fasta_index
  File dbSNP_vcf
  String modules

  command {
    set -eo pipefail

    gatk --java-options "-Xmx4g" \
      HaplotypeCaller \
      -R ${ref_fasta} \
      -I ${input_bam} \
      -O ${base_file_name}.GATK.vcf \
      --intervals ${intervals} \
      --interval-padding 100 
    }

  runtime {
    modules: "${modules}"
    memory: "30GB"
    cpu: 4
  }

  output {
    File output_vcf = "${base_file_name}.GATK.vcf"
    File output_vcf_index = "${base_file_name}.GATK.vcf.idx"
  }
}


# annotate with annovar
task annovar {
  File input_vcf
  String base_file_name
  String ref_name
  String annovar_protocols
  String annovar_operation
  String annovarDIR
  String modules
  String base_vcf_name = basename(input_vcf, ".vcf")
  
  command {
  set -eo pipefail
  
  perl ${annovarDIR}/annovar/table_annovar.pl ${input_vcf} ${annovarDIR}/annovar/humandb/ \
    -buildver ${ref_name} \
    -outfile ${base_vcf_name} \
    -remove \
    -protocol ${annovar_protocols} \
    -operation ${annovar_operation} \
    -nastring . -vcfinput
  }

  runtime {
    modules: "${modules}"
  }

  output {
    File output_annotated_vcf = "${base_file_name}.GATK.${ref_name}_multianno.vcf"
    File output_annotated_table = "${base_file_name}.GATK.${ref_name}_multianno.txt"
  }
}