package com.liubowang.dubbing.Record;

/**
 * Created by heshaobo on 2017/11/1.
 */

public interface RecordStreamListener {
    void recordOfByte(byte[] data, int begin, int end);
}
