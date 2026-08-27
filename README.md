
<a id="readme-top">S</a>


<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->


<!-- [![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![project_license][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url] -->



<!-- PROJECT LOGO -->
<!-- <br />
<div align="center">
  <a href="https://github.com/github_username/repo_name">
    <img src="images/logo.png" alt="Logo" width="80" height="80">
  </a> -->

<h3 align="center">Implementation Pipeline for SHiVAi</h3>

  <!-- <p align="center">
    project_description
    <br />
    <a href="https://github.com/github_username/repo_name"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/github_username/repo_name">View Demo</a>
    &middot;
    <a href="https://github.com/github_username/repo_name/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
    &middot;
    <a href="https://github.com/github_username/repo_name/issues/new?labels=enhancement&template=feature-request---.md">Request Feature</a>
  </p> -->
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#project-contents-roadmap">Project Contents Roadmap</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#running-the-pipeline">Running SHiVAi Pipeline</a></li>
      </ul>
    </li>
    <li><a href="#useful-commands">Useful Commands</a></li>
      <li><a href="#save-reports">Save Reports</a></li>
      <li><a href="#monitor-slurm-job-progress">Monitor SLURM job progress</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT --> 
<!-- Revise -->
## About The Project


The purpose of this pipeline is threefold: 
1. standardize input dataset into format SHiVAi pipeline accepts (for us it's BIDS) 
2. use pre-computed brain parcellations 
3. submit the job to a compute cluster with minimal code 



<!-- ROADMAP -->
## Project Contents Roadmap
```
SHiVAi_master/
├── crashes/                     # contains crash logs from `nipype` (generated)
├── logs/                        # SLURM job output logs (generated)
  ├── run_shiva.sh                  # SLURM submission script
├── models/                      # downloaded AI model weights and brainmask (see [SHiVAi documentation]()) 
  ├──brainmask
  ├──SWI-CMB
  ├──T1-PVS
  ├──T1.FLAIR-LAC
  ├──T1.FLAIR-PVS
  ├──T1.FLAIR-WMH
├── shivai_bids_input/           # SYMLINKED input files in the BIDS layout SHiVAi expects (both for raw and seg)(generated)
  ├──sub-xxxx
  ├──sub-xxxx
├── shivai_results/              # pipeline output (generated)
  ├──main_workflow
  ├──results
    ├──report
      ├──sub-xxxx
      ├──sub-xxxx
    ├──results_summary
    ├──segmentations
    ├──shiva_preproc
├── shivai_test/                # raw BIDS MRI data for testing (90 subjects) 
├── shiva_symlinks.py           # builds shivai_bids_input/ from raw data + FreeSurfer segs
├── check_files_1.sh            # inspects raw data / FreeSurfer folder patterns
├── shivai_0.5.9.sif            # Apptainer/Singularity container image 
├── config_example.yml          # pipeline configuration 
└── README.md                   # project documentation
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- GETTING STARTED -->
## Getting Started

There are couple of prerequisites to run SHiVai pipeline. Firstly, create a new virtual environment (conda or venv). Secondly, install `shivai`, and `pyyaml` as outlined in the <a href="">SHiVAi documentation</a>. Thirdly, connect to a submit server with `getserver -sb`. Finally, activate `shivai` and make sure to `cd` to the project folder. 

<!-- RUNNING THE PIPELINE -->
### Running The SHiVai Pipeline

1. Inspect dataset organization and its contents.

```sh
  bash check_files_1.sh > report_1.txt
```
Run `check_files_1.sh`with the following command to get information on how a given dataset is organized, and save the output into a `.txt` file. Saving the output is optional but highly recommended (see more under <a href="#useful-commands">Useful commands</a>). 


For our purposes, `check_files_1.sh` showcases the information of two datasets: `pt_life_raw`, which contains raw subject MRI data, and `freesurfer_all`, which contains the brain parcellations of those subjects. 



2. Create symlinks.

```sh
  python shiva_symlinks.py 
```
Run `shiva_symlinks.py` to create symlinks in BIDS format from datasets, and save the output. The script iterates over subjects and builds symlinks into `shivai_bids_input/` folder. Additionally, it handles brain parcellations, creating symlinks for segmentations. See  <a href=#r> </a>. 

3. Run `run_shiva.sh` to start the SHiVAi pipeline.

```sh
  sbatch logs/run_shiva.sh
```

`run_shiva.sh` contains the script for both submitting the job to cluster server and starting the SHiVAi piepeline, so you only need to submit the job on the terminal. The script outputs the log files, to track the progress. See [<a href="">________</a> and <a href="">________</a>] for more information on how to monitor progress.

4. Check the output in the `results` folder

Please reference [SHiVAi documentation]() to double check the contents of `results`.


<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USEFUL COMMANDS -->

## Useful Commands

### Save Reports

Use the following commands to save a progress report for `shiva_symlinks.py` or `cehck_files.sh` or `run_shiva.sh` (or for any other files). Progress report is basically the *output stream* of any script. 

Note: if the file with report already exists (for ex, `old_report.txt`), by using these commands the existing file gets *overwritten* (e.g with new `new_report.txt`). To get the contents of the new file *appended*, see the examples below. 

1. See the output live on the terminal AND save it. 

```bash
command script_name| tee output_file.txt
```
<br>

To append it, use `-a`: 
```sh
command script_name| tee -a output_file.txt
``` 
<br>

For example, `check_files.sh`: 
```sh
bash check_files.sh | tee -a report_1.txt
```
<br>

2. Redirect it to a file (no live terminal output). 
```sh
command script_name > output_file.txt
```
<br>

To append it, use an extra `>`:
```sh
command script_name >> output_file.txt
```
<br>

You can save the output into a specific directory for any of those commands with full or relative path: 
```sh
command script_name | tee relative_path/output_file.txt
```
<br>

### Monitor SLURM job progress

1. See the output of the `run_shiva.sh` live on your terminal 

```sh
tail -f <path/job_title>_<job_id>.out
```
You can find the job title in `run_shiva.sh` at `#SBATCH --job-title = shivai`. `job_id` will be displayed on your terminal each time you submit a job with `sbatch logs/run_shiva.sh` command, as `Submitted <job_id>`. 

<br>

For `run_shiva.sh`:

```sh
tail -f logs/shivai_9999.out
```

To stop the live output, press `CTRL+C`, which will only stop the `tail` command and to your regular shell prompt. It will not cancel any `SLURM` job. 
<br>

2. See the job information

Output the information about job (such as resources, time, queue etc.):

```sh
scontrol show job <job_id>
```
<br>

Job status (e.g is it running?): 

```sh
squeue -u $USER
```
<br>

Summary after job completion: 
```sh
seff <job_id>
```
<br>

Information about resource usage after job completion: 

```sh
sacct -j <jobid> 
```
<br>




_For more examples, please refer to the [Documentation](https://example.com)_

<p align="right">(<a href="#readme-top">back to top</a>)</p>



- [ ]
- [ ] Feature 2
- [ ] Feature 3
    - [ ] Nested Feature

See the [open issues](https://github.com/github_username/repo_name/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>




CONTACT
## Contact

Your Name - [@twitter_handle](https://twitter.com/twitter_handle) - email@email_client.com

Project Link: [https://github.com/github_username/repo_name](https://github.com/github_username/repo_name)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS
## Acknowledgments

* []()
* []()
* []()

<p align="right">(<a href="#readme-top">back to top</a>)</p> -->

