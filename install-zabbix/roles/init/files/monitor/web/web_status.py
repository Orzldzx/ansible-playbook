#!/usr/bin/env python
# -*- coding: utf-8 -*-
# 1un
# 2018-01-17

import sys
import fire
import pycurl
import StringIO


class WebStatus():

    def __init__(self, url, webresult):

        self.r = webresult
        self.b = StringIO.StringIO()

        self.c = pycurl.Curl()
        self.c.setopt(pycurl.URL, url)
        self.c.setopt(pycurl.TIMEOUT, 2)
        self.c.setopt(pycurl.NOPROGRESS, 1)
        self.c.setopt(pycurl.WRITEFUNCTION, self.b.write)

    def ExecCurl(self):
        try:
            self.c.perform()
            self.rcode = 0
        except pycurl.error as e:
            # print(e[1])
            print(e[0])
            sys.exit(e[0])

    def GetCode(self):
        self.ExecCurl()
        print(self.c.getinfo(pycurl.HTTP_CODE))
        self.__close()

    def GetResult(self):
        self.ExecCurl()
        if self.b.getvalue() == self.r:
            print(1)
        else:
            print(0)
        self.__close()

    def GetTotalTime(self):
        self.ExecCurl()
        t = self.c.getinfo(pycurl.TOTAL_TIME)
        print(round(t * 1000, 2))
        self.__close()

    def GetDownloadSpeed(self):
        self.ExecCurl()
        t = self.c.getinfo(pycurl.SPEED_DOWNLOAD)
        print(int(t) * 1024)
        self.__close()

    def GetRCode(self):
        self.ExecCurl()
        print(self.rcode)

    def __close(self):
        self.b.close()
        self.c.close()


if __name__ == '__main__':
    fire.Fire(WebStatus)
