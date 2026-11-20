local Theme = {}

Theme.Colors = {
    Background = Color3.fromRGB(8, 10, 18),
    Surface = Color3.fromRGB(15, 18, 30),
    SurfaceRaised = Color3.fromRGB(23, 27, 43),
    SurfaceHover = Color3.fromRGB(31, 36, 56),
    Border = Color3.fromRGB(57, 67, 94),
    Text = Color3.fromRGB(244, 246, 255),
    Muted = Color3.fromRGB(145, 155, 181),
    Violet = Color3.fromRGB(151, 105, 255),
    Cyan = Color3.fromRGB(71, 218, 255),
    Green = Color3.fromRGB(81, 224, 164),
    Red = Color3.fromRGB(255, 100, 126),
}

Theme.Dimensions = {
    DesktopWidth = 760,
    DesktopHeight = 490,
    MobileWidth = 350,
    MobileHeight = 440,
    SidebarWidth = 166,
    HeaderHeight = 66,
}

Theme.Font = {
    Heading = Enum.Font.GothamBold,
    Body = Enum.Font.Gotham,
    Medium = Enum.Font.GothamMedium,
    Strong = Enum.Font.GothamSemibold,
}

return Theme
