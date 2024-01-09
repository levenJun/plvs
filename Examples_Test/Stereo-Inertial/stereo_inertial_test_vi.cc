/**
* This file is part of ORB-SLAM3
*
* Copyright (C) 2017-2021 Carlos Campos, Richard Elvira, Juan J. Gómez Rodríguez, José M.M. Montiel and Juan D. Tardós, University of Zaragoza.
* Copyright (C) 2014-2016 Raúl Mur-Artal, José M.M. Montiel and Juan D. Tardós, University of Zaragoza.
*
* ORB-SLAM3 is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* ORB-SLAM3 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
* the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License along with ORB-SLAM3.
* If not, see <http://www.gnu.org/licenses/>.
*/

#include<iostream>
#include<algorithm>
#include<fstream>
#include<chrono>
#include <ctime>
#include <sstream>

#include<opencv2/core/core.hpp>

#include<System.h>
#include "ImuTypes.h"
#include "HeadDataReader.h"

using namespace std;

#include<execinfo.h>
#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include <signal.h>

static void WidebrightSegvHandler(int signum)
{
	void *array[10];
	size_t size;
	char **strings;
	size_t i, j;
	signal(signum, SIG_DFL); /* 还原默认的信号处理handler */
 
	size = backtrace (array, 10);
	strings = (char **)backtrace_symbols (array, size);
 
	fprintf(stderr, "widebright received SIGSEGV! Stack trace:\n");
	for (i = 0; i < size; i++) {
		fprintf(stderr, "%d %s \n",i,strings[i]);
	}
	
	free (strings);
	exit(1);
}

// #define BOOST_STACKTRACE_USE_ADDR2LINE
// #include <boost/stacktrace.hpp>

// // This is definitely not async-signal-safe. Let's hope it doesn't crash or hang.
// void handler(int signo)
// {
//     if (std::ofstream file_stream("my_stacktrace.log", std::ios::trunc); file_stream.is_open())
//     {
//         std::stringstream ss;
//         ss <<  boost::stacktrace::stacktrace();
//         std::cout << boost::stacktrace::stacktrace() << std::endl;
//         file_stream.write(ss.str().c_str(), ss.str().size());
//         file_stream.close();
//     }

//     // Raise signal again. Should usually terminate the program.
//     raise(signo);
// }

double ttrack_tot = 0;
int main(int argc, char **argv)
{
	//设置 信好的处理函数
	signal(SIGSEGV, WidebrightSegvHandler); // SIGSEGV	  11	   Core	Invalid memory reference
	signal(SIGABRT, WidebrightSegvHandler); // SIGABRT	   6	   Core	Abort signal from
	
    // // // Repeat this for each signal you want to catch and log.
    // // struct sigaction act{};
    // // // Allow signal handler to re-raise signal and reset to default handler after entering.
    // // act.sa_flags = SA_NODEFER | SA_RESETHAND;
    // // act.sa_handler = &handler;
    // // sigfillset(&act.sa_mask);
    // // sigdelset(&act.sa_mask, SIGSEGV /* or other signal */);
    // // if (sigaction(SIGSEGV /* or other signal */, &act, nullptr) == -1)
    // //     std::exit(EXIT_FAILURE);

    const int num_seq = 1;
    cout << "num_seq = " << num_seq << endl;
    bool bFileName= true;
    string file_name;
    if (bFileName)
        file_name = "head_test_h";

    if(argc < 4) 
    {
        cerr << endl << "Usage: ./stereo_inertial_tum_vi path_to_vocabulary path_to_settings path_to_image_folder_1 path_to_image_folder_2 path_to_times_file path_to_imu_data (trajectory_file_name)" << endl;
        return 1;
    }

    string dataDir = string(argv[3]);
    cout << "dataDir = " << dataDir << endl;

    // Load all sequences:
    int seq;
    vector< vector<string> > vstrImageLeftFilenames;
    vector< vector<string> > vstrImageRightFilenames;
    vector< vector<double> > vTimestampsCam;
    vector< vector<cv::Point3f> > vAcc, vGyro;
    vector< vector<double> > vTimestampsImu;
    vector<int> nImages;
    vector<int> nImu;
    vector<int> first_imu(num_seq,0);

    vstrImageLeftFilenames.resize(num_seq);
    vstrImageRightFilenames.resize(num_seq);
    vTimestampsCam.resize(num_seq);
    vAcc.resize(num_seq);
    vGyro.resize(num_seq);
    vTimestampsImu.resize(num_seq);
    // nImages.resize(num_seq);
    nImu.resize(num_seq);

    int tot_images = 0;

    int startIndex = 0;
    int endIndex = 90000;

    std::shared_ptr<DATA_READER::HeadDataReader> headDataReader 
                = std::make_shared<DATA_READER::HeadDataReader>(dataDir + "/head", 4, 1, startIndex, endIndex);
    seq = 0;

    // Vector for tracking time statistics
    // nImages[seq] = headDataReader->getCamNum(0);
    tot_images = headDataReader->getImgSize(0);

    if((tot_images<=0))
    {
        cerr << "ERROR: Failed to load images or IMU for sequence" << seq << endl;
        return 1;
    }

    vector<float> vTimesTrack;
    // vTimesTrack.resize(tot_images);

    cout << endl << "-------" << endl;
    cout.precision(17);

    /*cout << "Start processing sequence ..." << endl;
    cout << "Images in the sequence: " << nImages << endl;
    cout << "IMU data in the sequence: " << nImu << endl << endl;*/

    // Create SLAM system. It initializes all system threads and gets ready to process frames.
    PLVS2::System SLAM(argv[1],argv[2],PLVS2::System::IMU_STEREO, true, 0, file_name);
    float imageScale = SLAM.GetImageScale();

    double t_resize = 0.f;
    double t_track = 0.f;

    int proccIm = 0;
    // for (seq = 0; seq<num_seq; seq++)
    {

        // Main loop
        cv::Mat imLeft, imRight;
        vector<PLVS2::IMU::Point> vImuMeas;
        proccIm = 0;
        cv::Ptr<cv::CLAHE> clahe = cv::createCLAHE(3.0, cv::Size(8, 8));


        while (headDataReader->isRun() || !headDataReader->isDataBufferEmpty())
        {
            DATA_READER::Data data_head = headDataReader->read();
            if (data_head.videoFrame.stamp < 1)
            {
                usleep(1);
                continue;
            }
        //    if(data_head.videoFrame.stamp >30.0)
            //   {
            //   break;
            //  }
            // Load imu measurements from previous frame
            vImuMeas.clear();
            int imuSize = data_head.headImuPredict.imus.size();       
            for(int indexImu = 0; indexImu < imuSize; indexImu++){
                DATA_READER::IMUFrame& curImu = data_head.headImuPredict.imus[indexImu];
                vImuMeas.push_back(PLVS2::IMU::Point(curImu.acc(0),curImu.acc(1),curImu.acc(2),
                                                            curImu.gro(0),curImu.gro(1),curImu.gro(2),
                                                            curImu.stamp));
            }

            // Read image from file
            imLeft = data_head.videoFrame.im[0];
            imRight = data_head.videoFrame.im[1];

            if(imageScale != 1.f)
            {
#ifdef REGISTER_TIMES
    #ifdef COMPILEDWITHC11
                std::chrono::steady_clock::time_point t_Start_Resize = std::chrono::steady_clock::now();
    #else
                std::chrono::monotonic_clock::time_point t_Start_Resize = std::chrono::monotonic_clock::now();
    #endif
#endif
                int width = imLeft.cols * imageScale;
                int height = imLeft.rows * imageScale;
                cv::resize(imLeft, imLeft, cv::Size(width, height));
                cv::resize(imRight, imRight, cv::Size(width, height));
#ifdef REGISTER_TIMES
    #ifdef COMPILEDWITHC11
                std::chrono::steady_clock::time_point t_End_Resize = std::chrono::steady_clock::now();
    #else
                std::chrono::monotonic_clock::time_point t_End_Resize = std::chrono::monotonic_clock::now();
    #endif
                t_resize = std::chrono::duration_cast<std::chrono::duration<double,std::milli> >(t_End_Resize - t_Start_Resize).count();
                SLAM.InsertResizeTime(t_resize);
#endif
            }

            if(false){
                // clahe
                clahe->apply(imLeft,imLeft);
                clahe->apply(imRight,imRight);
            }else{
                //另外的方式作图像增强
                cv::Scalar meanLeft =cv::mean(imLeft);
                cv::Scalar meanRight =cv::mean(imRight);

                imLeft=(imLeft-meanLeft[0]*0.1);
                meanLeft=cv::mean(imLeft);
                float scaleLeft=128.0/meanLeft[0];
                imLeft=(imLeft)*scaleLeft;


                imRight=(imRight-meanRight[0]*0.1);
                meanRight=cv::mean(imRight);
                float scaleRight=128.0/meanRight[0];
                imRight=(imRight)*scaleRight;
            }

            double tframe = data_head.videoFrame.stamp;

            if(imLeft.empty() || imRight.empty())
            {
                cerr << endl << "Failed to load image at: "
                     <<  data_head.videoFrame.stamp << endl;
                return 1;
            }

    #ifdef COMPILEDWITHC11
            std::chrono::steady_clock::time_point t1 = std::chrono::steady_clock::now();
    #else
            std::chrono::monotonic_clock::time_point t1 = std::chrono::monotonic_clock::now();
    #endif

            // Pass the image to the SLAM system
            SLAM.TrackStereo(imLeft,imRight,tframe,vImuMeas);

    #ifdef COMPILEDWITHC11
            std::chrono::steady_clock::time_point t2 = std::chrono::steady_clock::now();
    #else
            std::chrono::monotonic_clock::time_point t2 = std::chrono::monotonic_clock::now();
    #endif

#ifdef REGISTER_TIMES
            t_track = t_resize + std::chrono::duration_cast<std::chrono::duration<double,std::milli> >(t2 - t1).count();
            SLAM.InsertTrackTime(t_track);
#endif

            double ttrack= std::chrono::duration_cast<std::chrono::duration<double> >(t2 - t1).count();
            ttrack_tot += ttrack;
            // std::cout << "ttrack: " << ttrack << std::endl;

            vTimesTrack.push_back(ttrack);
            // vTimesTrack[ni]=ttrack;

            usleep(1000 * 30);
            proccIm++;
        }
    }


    // Stop all threads
    SLAM.Shutdown();

    // Tracking time statistics

    // Save camera trajectory
    std::chrono::system_clock::time_point scNow = std::chrono::system_clock::now();
    std::time_t now = std::chrono::system_clock::to_time_t(scNow);
    std::stringstream ss;
    ss << now;

    if (bFileName)
    {
        const string kf_file =  "kf_" + file_name + ".txt";
        const string f_file =  "f_" + file_name + ".txt";
        SLAM.SaveTrajectoryEuRoC(f_file);
        SLAM.SaveKeyFrameTrajectoryEuRoC(kf_file);
    }
    else
    {
        SLAM.SaveTrajectoryEuRoC("CameraTrajectory.txt");
        SLAM.SaveKeyFrameTrajectoryEuRoC("KeyFrameTrajectory.txt");
    }

    sort(vTimesTrack.begin(),vTimesTrack.end());
    float totaltime = 0;
    for(int ni=0; ni<vTimesTrack.size(); ni++)
    {
        totaltime+=vTimesTrack[ni];
    }
    cout << "-------" << endl << endl;
    cout << "median tracking time: " << vTimesTrack[vTimesTrack.size()/2] << endl;
    cout << "mean tracking time: " << totaltime/proccIm << endl;

    return 0;
}
