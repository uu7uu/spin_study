import numpy as np
from collections import defaultdict

def read_data(filename):
    """读取数据并解析为 mass, incl, dist 和 a 的字典."""
    data_dict = defaultdict(list)  # 使用 defaultdict 来存储 a 值
    with open(filename, 'r') as file:
        for line in file:
            parts = line.strip().split()
            a_value = float(parts[12])
            # 提取最后一列数据
            last_col = parts[-1]  # 获取最后一列
            last_parts = last_col.split('_')  # 使用 '_' 分隔
            
            # 提取 mass, incl, dist
            try:
                mass = float(last_parts[-4])  # 倒数第三个元素为 mass
                incl = float(last_parts[-3])  # 倒数第二个元素为 incl
                dist = float(last_parts[-2])  # 最后一个元素为 dist
            except (IndexError, ValueError):
                print(f"无法解析行: {line.strip()}")
                continue
            # 将 a 值添加到对应的 mass, incl, dist 组
            data_dict[(mass, incl, dist)].append(a_value)
    
    return data_dict

def calculate_average(data_dict):
    """计算每组 mass, incl, dist 的 a 值平均值."""
    averages = {}
    for key, values in data_dict.items():
        avg_a = np.mean(values)  # 计算平均值
        averages[key] = avg_a
    return averages

def write_results(averages, output_filename):
    """将结果写入新的文本文件."""
    with open(output_filename, 'w') as file:
        for key, avg in averages.items():
            mass, incl, dist = key
            file.write(f"{mass} {incl} {dist} {avg}\n")


def main():
    filename = 'grid_result.txt'  # 请替换为你的文件名
    output_filename = 'grid_average.txt'  # 输出文件名

    data_dict = read_data(filename)
    averages = calculate_average(data_dict)

    write_results(averages, output_filename)
    print(f"结果已写入 {output_filename}")

if __name__ == "__main__":
    main()