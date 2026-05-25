# 安装和加载必要的包
install.packages(c("terra", "sf"))
library(terra)
library(sf)

# 设置工作目录
setwd("D:/植被指数/施工前拼接")

# 列出所有影像文件（假设都是tif格式）
image_files <- list.files(pattern = "\\.tif$", full.names = TRUE)
cat("找到的影像文件:\n")
print(basename(image_files))

# 检查影像数量
if (length(image_files) != 6) {
  cat("警告：找到", length(image_files), "个文件，但预期6个\n")
}

# 方法1：使用terra包拼接（修正版本）
simple_mosaic <- function(image_files, output_name = "mosaic_simple.tif") {
  # 加载所有影像
  images <- list()
  for (i in 1:length(image_files)) {
    images[[i]] <- rast(image_files[i])
    cat("加载第", i, "幅影像:", basename(image_files[i]), "\n")
  }
  
  # 使用merge函数拼接所有影像
  result <- images[[1]]
  
  if (length(images) > 1) {
    for (i in 2:length(images)) {
      cat("正在拼接第", i, "幅影像...\n")
      result <- merge(result, images[[i]])
    }
  }
  
  # 保存结果
  writeRaster(result, output_name, overwrite = TRUE)
  cat("拼接完成，结果保存为:", output_name, "\n")
  
  return(result)
}

# 执行简单拼接
mosaic_simple <- simple_mosaic(image_files, "施工前影像拼接.tif")

# 查看拼接结果信息（修正的打印方式）
cat("拼接结果信息:\n")
print(mosaic_simple)

# 获取范围并正确打印
mosaic_ext <- ext(mosaic_simple)
cat(sprintf("范围: xmin=%.4f, xmax=%.4f, ymin=%.4f, ymax=%.4f\n", 
            mosaic_ext$xmin, mosaic_ext$xmax, mosaic_ext$ymin, mosaic_ext$ymax))

cat("分辨率: X=", res(mosaic_simple)[1], ", Y=", res(mosaic_simple)[2], "\n", sep="")
cat("投影:", crs(mosaic_simple, describe=TRUE)$name, "\n")
cat("波段数:", nlyr(mosaic_simple), "\n")

# 添加一个简单的可视化
plot_mosaic_preview <- function(mosaic_result, output_plot = "拼接预览.png") {
  # 如果是多波段影像，使用RGB合成
  if (nlyr(mosaic_result) >= 3) {
    # 提取RGB波段
    rgb_bands <- mosaic_result[[1:3]]
    
    # 创建一个预览（降低分辨率以加快显示）
    preview <- aggregate(rgb_bands, fact=5)  # 降低5倍分辨率
    
    png(output_plot, width=1200, height=900, res=150)
    plotRGB(preview, r=1, g=2, b=3, stretch="lin",
            main="影像拼接预览 (RGB合成)", axes=FALSE)
    dev.off()
  } else {
    # 单波段影像
    png(output_plot, width=1200, height=900, res=150)
    plot(mosaic_result, main="影像拼接预览", col=terrain.colors(100))
    dev.off()
  }
  cat("预览图已保存:", output_plot, "\n")
}

# 创建预览图
plot_mosaic_preview(mosaic_simple, "拼接预览.png")