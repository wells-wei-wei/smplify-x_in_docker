FROM nvidia/cudagl:10.0-devel-ubuntu18.04

#更改apt源
COPY sources.list etc/apt
RUN apt-get update

RUN apt-get install python3 -y && apt install python3-pip -y
RUN apt-get install openssl -y && apt-get install libssl-dev -y
RUN apt-get install git -y
RUN apt-get install wget -y
RUN apt-get install mlocate -y && updatedb
RUN apt-get install vim -y

#安装cmake，也可以根据自己的情况选择其他合适的版本，不得低于3.14
COPY cmake-3.17.1/. /root/cmake/
RUN cd /root/cmake/ && ./bootstrap && make -j8 && make install && ln -s /usr/local/bin/cmake /usr/bin/cmake

#安装boost，也可以根据自己的情况选择其他合适的版本
COPY boost_1_72_0/. /root/boost/
RUN cd /root/boost/ && ./bootstrap.sh && ./b2 install

#安装opencv，也可以根据自己的情况选择其他合适的版本
COPY opencv-4.2.0/. /root/opencv/
RUN cd /root/opencv/ && mkdir build && cd build && cmake .. && make -j20 && make install

# 安装cudnn10
RUN cd /root/ && wget http://file.ppwwyyxx.com/nvidia/cudnn-10.0-linux-x64-v7.6.4.38.tgz && tar -xzf cudnn-10.0-linux-x64-v7.6.4.38.tgz -C /usr/local && ldconfig

#安装openpose
COPY openpose/. /root/openpose/
RUN apt-get install libprotobuf-dev protobuf-compiler -y && apt-get install libgoogle-glog-dev -y && apt-get install libhdf5-dev -y && apt-get install libatlas-base-dev -y

RUN cd /root/openpose/ && mkdir build && cd build && cmake -DBUILD_PYTHON=ON .. && make -j20 && cp -r python/openpose /usr/local/lib/python3.6/dist-packages/

RUN apt-get install libsm6 libxrender1 libfontconfig1 libxext6 -y && apt-get install freeglut3-dev -y

#安装torch-mesh-isect
COPY torch-mesh-isect/. /root/torch-mesh-isect/
RUN pip3 install torch==1.1.0
RUN cd /root/torch-mesh-isect/ && python3 setup.py install 

COPY playing_smplifyx/. /home/playing_smplifyx/
RUN cd /home/playing_smplifyx/ && pip3 install -r requirements.txt 
RUN pip3 install git+https://github.com/nghorbani/configer
RUN pip3 install git+https://github.com/nghorbani/human_body_prior

#安装ssh，可以进行远程调试
RUN apt-get install xorg -y
RUN apt-get install openbox -y
RUN apt-get install -y openssh-server
#RUN mkdir /var/run/sshd
RUN echo 'root:wei' | chpasswd
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
RUN echo 'Port 22' >> /etc/ssh/sshd_config
RUN mkdir /run/sshd
#RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
#RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
#ENV NOTVISIBLE "in users profile"
#RUN echo "export VISIBLE=now" >> /etc/profile
EXPOSE 22
WORKDIR /home
CMD ["/usr/sbin/sshd", "-D"]
