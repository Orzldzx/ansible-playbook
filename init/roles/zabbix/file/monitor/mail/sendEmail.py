#!/usr/bin/env python
# -*- coding: utf-8 -*-
# 1un
# 2016-04-19

import smtplib, os
from email.header import Header
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

'''
    功能:
    可发送纯文本邮件.
    可发送带附件的纯文本邮件.

    描述:
    mailToList: 收件人 | me: 标题 | sub: 主题 | content: 邮件内容 | att: 附件内容

    使用:
    filename.sendMail(stmp服务器, 发件人, 发件人密码, [ 收件人 ], 发件人样式,
                      邮件主题, 邮件内容, {编号 : [附件名, 附件描述]})
'''

def sendMail(mailHost,mailUser,mailPass,mailToList,me,sub,content,atts=None):
    '''
    发送纯文本带附件的邮件
    '''
    # -----
    me  = "{0}<{1}>".format(me,mailUser)    # 收到信后,按照设置显示发件箱
    # -----
    msg = MIMEMultipart()                   # 创建实例
    # -----
    msg['Subject'] = Header(sub ,'utf-8')   # 设置主题
    msg['From']    = me                     # 设置发件人样式
    msg['To']      = ';'.join(mailToList)   # 设置收件人列表
    # -----
    text = MIMEText(content,_subtype='plain',_charset='utf-8')
    # 创建一个实例,这里设置为text格式邮件, html格式邮件需要设置为: 增加 < _subtype='html' > 属性
    msg.attach(text)
    # -----
    if atts:
        for attnum,att in atts.items():
            if not os.path.exists(att[0]):
                print '跳过: 未找到文件', att[0]
                continue
            n = 'att'+str(attnum)
            n = MIMEText(open(att[0], 'rb').read(), 'base64', 'utf-8')
            n['Content-Type'] = 'application/octet-stream'
            n['Content-Disposition'] = 'attachment; filename={0}'.format(att[1])
            # 这里的filename可以任意写, 写什么名字, 邮件中显示什么名字
            msg.attach(n)
    # -----
    try:
        s = smtplib.SMTP()
        s.connect(mailHost)                         # 连接smtp服务器
        s.login(mailUser,mailPass)                  # 登陆服务器
        s.sendmail(me, mailToList, msg.as_string()) # 发送邮件
        s.close()                                   # 关闭连接
        return True
    except Exception, e:
        print str(e)
        return False

# -------------------

if __name__ == '__main__':
    mailHost    = "xxx.xx.com"  # 设置服务器
    mailUser    = "xxx@yyy.com" # 用户名
    mailPass    = "xxxxxx"      # 密码
    # -----
    me         = 'XimiYW'       # 发件人样式
    sub        = '测试邮件主题'  # 邮件主题
    content    = '测试邮件内容'  # 邮件内容
    # 收件人列表
    mailToList = ['xieyajun@ximigame.com',
                  'liuliqiao@ximigame.com']
    # 附件
    atts = { 1:['/tmp/test','测试邮件附件1'],
             2: [ '/tmp/test2', '测试邮件附件2' ]}
    # -----
    if sendMail(mailHost,mailUser,mailPass,mailToList,me,sub,content,atts): print '发送成功'
    else: print '发送失败'
