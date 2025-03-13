//
//  Environment.swift
//  Packages
//
//  Created by 박서연 on 1/3/25.
//

@preconcurrency import ProjectDescription

public enum Environment {
    public static let appName: String = "TnTApp"
    public static let organizationName = "yapp25thTeamTnT"
    public static let destinations: Destinations = [.iPhone]
    public static let deploymentTarget: DeploymentTargets = .iOS("17.0")
}
