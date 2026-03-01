package com.noharayh.otokit;

import java.util.ArrayList;
import java.util.List;

public class DataContext {
    public static String Username = null;

    public static String Password = null;

    public static boolean CopyUrl = true;

    public static boolean AutoLaunch = true;

    public static String HookHost = "127.0.0.1:8284";

    public static String WebHost = "";

    public static String ProxyHost = "proxy.bakapiano.com";

    public static int ProxyPort = 2569;

    public static boolean CompatibleMode = false;

    public static int GameType = 0; // 0: maimai, 1: chunithm
    public static String LxnsUploadUrl = "";
    public static String DfUploadUrl = "";
    public static String WahlapAuthUrl = "";
    public static List<Integer> Difficulties = new ArrayList<>();
    public static List<String> GenreList = new ArrayList<>();
    public static java.util.Map<Integer, String> FetchUrlMap = new java.util.HashMap<>();
}
