package com.noharayh.toolbox.crawler

interface WechatCrawlerListener {
    fun onMessageReceived(message: String)
    fun onStartAuth()
    fun onFinishUpdate()
    fun onError(e: Exception)
}
