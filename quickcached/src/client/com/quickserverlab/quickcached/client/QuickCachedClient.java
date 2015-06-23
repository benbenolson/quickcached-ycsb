package com.yahoo.ycsb.db;

import java.io.*;
import java.util.*;
import java.util.concurrent.TimeoutException;

import com.yahoo.ycsb.ByteArrayByteIterator;
import com.yahoo.ycsb.ByteIterator;
import com.yahoo.ycsb.DB;
import com.yahoo.ycsb.DBException;

import com.quickserverlab.quickcached.client.MemcachedException;
import com.quickserverlab.quickcached.client.impl.QuickCachedClientImpl;


public class QuickCachedClient extends DB
{
  QuickCachedClientImpl c;

  public void init() throws DBException {
    c = new QuickCachedClientImpl();
    Properties props = getProperties();
    c.setAddresses("127.0.0.1:11211");
    try {
      c.init();
    } catch(Exception ex) {
      System.err.println("CANNOT CONNECT TO SERVER!");
    }
//    c = new QuickCachedClientImpl(new InetSocketAddress("127.0.0.1", 11211));
  }
  
  @Override
  public int delete(String table, String key)
  {
    try {
      c.delete(table + ":" + key, 3600);
    } catch(Exception ex) {
    }
    return 0;
  }

  @Override
  public int insert(String table, String key, HashMap<String, ByteIterator> values)
  {
    try {
      c.set(table + ":" + key, 3600, values, 3600);
    } catch(Exception ex) {
    }
    return 0;
  }
  
  @Override
  public int update(String table, String key, HashMap<String, ByteIterator> values)
  {
    insert(table, key, values);
    return 0;
  }
  
  @Override
  public int scan(String table, String startkey, int recordcount, Set<String> fields,
                  Vector<HashMap<String, ByteIterator>> result)
  {
    System.out.println("Scanning doesn't work yet.");
    return 1;
  }

  @Override
  public int read(String table, String key, Set<String> fields, HashMap<String, ByteIterator> result)
  {
    try {
      Object obj = c.get(table + ":" + key, 3600);
      result = (HashMap<String, ByteIterator>) obj;
    } catch(Exception ex) {
    }
    return 0;
  }
}
