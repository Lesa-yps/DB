import copy

cnt = 0

def check(a, ans):
    for item in ans:
        if (abs(item[0] - a[0]) == abs(item[1] - a[1])):
            return False
    return True

def copy_lst_i(ans, lst):
    max = -1
    for item in ans:
        if item[0] > max:
            max = item[0]
    for i in range(len(lst)):
        if lst[i] > max:
            return copy.deepcopy(lst[i:])
    return []
    
def f(ans, lst):
  global cnt
  lst_i = copy_lst_i(ans, lst[0])
  for i in lst_i:
    for j in lst[1]:
      # print(i, j)
      if check((i, j), ans):
        new_ans = copy.deepcopy(ans)
        new_ans.append((i, j))
        if len(new_ans) == 8:
          cnt += 1
          print(new_ans)
          return 
        new = copy.deepcopy(lst)
        new[0].remove(i)
        new[1].remove(j)
        # print(new)
        f(new_ans, new)

mat = [[i for i in range(8)] for _ in range(2)]
ans = []
f(ans, mat)
print(cnt)