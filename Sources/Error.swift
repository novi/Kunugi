//
//  Error.swift
//  Kunugi
//
//  Created by ito on 1/3/16.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//

public enum MiddewareError: ErrorType {
    case NoContextType(String)
    case AlreadyHasContextType(String)
}
