﻿using System;
using System.Collections.Generic;

public interface IWordFilter
{
    void AddKey(string key);
    bool HasBadWord(string text);
    string FindOne(string text);
    List<string> FindAll(string text);
    string Replace(string text);
}